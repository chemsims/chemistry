//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationWeakSubstancePreparationModel: ObservableObject {
    init(
        substance: AcidOrBase,
        titrant: Titrant,
        cols: Int,
        rows: Int,
        settings: TitrationSettings,
        maxReactionProgressMolecules: Int = AcidAppSettings.maxReactionProgressMolecules
    ) {
        let initialTitrantMolarity = AcidAppSettings.initialTitrantMolarity
        self.substance = substance
        self.titrant = titrant
        self.titrantMolarity = initialTitrantMolarity
        self.cols = cols
        self.exactRows = CGFloat(rows)
        self.settings = settings
        self.substanceCoords = BeakerMolecules(
            coords: [],
            color: substance.color,
            label: substance.chargedSymbol.symbol.label
        )
        self.reactionProgressModel = Self.initialReactionProgress(
            substance: substance,
            maxMolecules: maxReactionProgressMolecules
        )

        self.calculations = Calculations(
            substance: substance,
            titrant: titrant.name,
            titrantMolarity: initialTitrantMolarity,
            gridSizeFloat: CGFloat(cols * rows),
            substanceCoordsCount: 0,
            rows: rows,
            settings: settings
        )
    }

    @Published var substance: AcidOrBase {
        didSet {
            self.reactionProgressModel = Self.initialReactionProgress(
                substance: substance,
                maxMolecules: reactionProgressModel.settings.maxMolecules
            )
            self.substanceCoords = BeakerMolecules(
                coords: [],
                color: substance.color,
                label: substance.chargedSymbol.text.label
            )
            updateCalculations()
        }
    }
    let titrant: Titrant
    let cols: Int

    let settings: TitrationSettings

    @Published var exactRows: CGFloat {
        didSet {
            updateCalculations()
        }
    }

    @Published var substanceCoords: BeakerMolecules
    @Published var reactionProgress: CGFloat = 0
    @Published var substanceAdded = 0

    @Published var titrantMolarity: CGFloat {
        didSet {
            updateCalculations()
        }
    }

    @Published var reactionProgressModel: ReactionProgressChartViewModel<ExtendedSubstancePart>

    private var gridSizeFloat: CGFloat {
        CGFloat(cols * rows)
    }

    var rows: Int {
        GridCoordinateList.availableRows(for: exactRows)
    }

    private var calculations: Calculations
}

// MARK: - Reaction progress
extension TitrationWeakSubstancePreparationModel {

    func copyReactionProgress() -> ReactionProgressChartViewModel<ExtendedSubstancePart> {
        let original = reactionProgressModel
        self.reactionProgressModel = reactionProgressModel.copy()
        return original
    }

    // Updates reaction progress, ensuring there is always an even number of
    // substance molecules
    private func updateReactionProgress() {
        let currentPairs = reactionProgressModel.moleculeCounts(ofType: .substance) / 2
        let desiredPairs = reactionProgressMoleculePairCount.getY(at: CGFloat(substanceAdded)).roundedInt()

        let pairsToAdd = desiredPairs - currentPairs
        assert(pairsToAdd >= 0, "Expected number of pairs to add")

        if pairsToAdd > 0 {
            (0..<pairsToAdd).forEach { _ in
                _ = reactionProgressModel.addMolecules(.substance, count: 2, duration: 0.5)
            }
        }
    }

    private var reactionProgressMoleculePairCount: Equation {
        LinearEquation(
            x1: 0,
            y1: 0,
            x2: CGFloat(maxSubstance),
            y2: CGFloat(reactionProgressModel.settings.maxMolecules / 2)
        )
    }
}

// MARK: Incrementing
extension TitrationWeakSubstancePreparationModel {
    func incrementSubstance(count: Int) {
        let maxToAdd = min(count, remainingCountAvailable)
        guard maxToAdd > 0 else {
            return
        }
        substanceCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: substanceCoords.coords,
            count: maxToAdd,
            cols: cols,
            rows: rows
        )
        withAnimation(.linear(duration: 1)) {
            substanceAdded += maxToAdd
        }
        updateReactionProgress()
        updateCalculations()
    }
}

// MARK: - Calculation data access
extension TitrationWeakSubstancePreparationModel {
    private func updateCalculations() {
        self.calculations = Calculations(
            substance: substance,
            titrant: titrant.name,
            titrantMolarity: titrantMolarity,
            gridSizeFloat: gridSizeFloat,
            substanceCoordsCount: substanceCoords.coords.count,
            rows: rows,
            settings: settings
        )
    }

    var equationData: TitrationEquationData {
        calculations.equationData
    }

    var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> {
        calculations.concentration
    }

    var kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat> {
        calculations.kValues
    }

    var currentMolarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        calculations.molarity.map { $0.getY(at: CGFloat(reactionProgress)) }
    }

    var volume: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
        calculations.volume
    }

    var moles: EnumMap<TitrationEquationTerm.Moles, Equation> {
        calculations.moles
    }

    var barChartData: [BarChartData] {
        calculations.barChartData
    }

    var barChartDataMap: EnumMap<ExtendedSubstancePart, BarChartData> {
        calculations.barChartDataMap
    }

    var currentPH: CGFloat {
        equationData.pValues.value(for: .hydrogen).getY(at: reactionProgress)
    }

    var currentSubstanceMoles: CGFloat {
        moles.value(for: .substance).getY(at: reactionProgress)
    }
}

// MARK: - Equation data
private class Calculations {

    init(
        substance: AcidOrBase,
        titrant: String,
        titrantMolarity: CGFloat,
        gridSizeFloat: CGFloat,
        substanceCoordsCount: Int,
        rows: Int,
        settings: TitrationSettings
    ) {
        self.substance = substance
        self.titrant = titrant
        self.titrantMolarity = titrantMolarity
        self.gridSizeFloat = gridSizeFloat
        self.substanceCoordsCount = substanceCoordsCount
        self.rows = rows
        self.settings = settings
    }

    let substance: AcidOrBase
    let titrant: String
    let titrantMolarity: CGFloat
    let gridSizeFloat: CGFloat
    let substanceCoordsCount: Int
    let rows: Int
    let settings: TitrationSettings

    var equationData: TitrationEquationData {
            TitrationEquationData(
                substance: substance,
                titrant: "KOH", // TODO
                moles: moles,
                volume: volume.map { ConstantEquation(value: $0) },
                molarity: molarity,
                concentration: concentration
            )
        }

    lazy var kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat> =
        .init {
            switch $0 {
            case .kA: return substance.kA
            case .kB: return substance.kB
            }
        }

    // MARK: - Concentration
    lazy var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> =
        .init {
            switch $0 {
            case .substance: return substanceConcentration
            case .initialSubstance: return ConstantEquation(value: initialSubstanceConcentration)
            case .secondary, .initialSecondary: return ionConcentration
            case .hydrogen: return hydrogenConcentration
            case .hydroxide: return hydroxideConcentration
            }
        }

    private lazy var substanceConcentration =
        LinearEquation(
            x1: 0,
            y1: initialSubstanceConcentration,
            x2: 1,
            y2: initialSubstanceConcentration - changeInConcentration
        )

    private lazy var ionConcentration =
        LinearEquation(
            x1: 0,
            y1: 0,
            x2: 1,
            y2: changeInConcentration
        )

    private lazy var complementPrimaryIonConcentration: Equation =
        ionConcentration.map(PrimaryIonConcentration.complementConcentration)

    private var hydrogenConcentration: Equation {
        if substance.type.isAcid {
            return ionConcentration
        }
        return complementPrimaryIonConcentration
    }

    private var hydroxideConcentration: Equation {
        if substance.type.isAcid {
            return complementPrimaryIonConcentration
        }
        return ionConcentration
    }

    private lazy var changeInConcentration: CGFloat =
        AcidConcentrationEquations.changeInConcentration(
            substance: substance,
            initialSubstanceConcentration: initialSubstanceConcentration
        )

    private lazy var initialSubstanceConcentration =
        CGFloat(substanceCoordsCount) / gridSizeFloat


    // MARK: - Volume
    lazy var volume: EnumMap<TitrationEquationTerm.Volume, CGFloat> =
        .init {
            switch $0 {
            case .equivalencePoint: return 0
            case .hydrogen: return 0
            case .initialSecondary: return 0
            case .substance, .initialSubstance:
                return settings
                    .beakerVolumeFromRows
                    .getY(at: CGFloat(rows))
            case .titrant: return 0
            }
        }


    // MARK: - Moles
    lazy var moles: EnumMap<TitrationEquationTerm.Moles, Equation> =
        .init {
            switch $0 {
            case .substance:
                return volume.value(for: .substance) * concentration.value(for: .substance)
            case .initialSubstance:
                return volume.value(for: .initialSubstance) * concentration.value(for: .initialSubstance)
            case .secondary:
                return volume.value(for: .substance) * concentration.value(for: .secondary)
            case .initialSecondary:
                return volume.value(for: .initialSecondary) * concentration.value(for: .initialSecondary)
            case .hydrogen: return ConstantEquation(value: 0)
            case .titrant: return ConstantEquation(value: 0)
            }
        }


    // MARK: - Molarity
    lazy var molarity: EnumMap<TitrationEquationTerm.Molarity, Equation> =
        .init {
            switch $0 {
            case .hydrogen: return concentration.value(for: .hydrogen)
            case .substance: return concentration.value(for: .substance)
            case .titrant: return ConstantEquation(value: titrantMolarity)
            }
        }

    // MARK: - Bar chart
    lazy var barChartData: [BarChartData] = {
        let data = barChartDataMap
        return [
            data.value(for: .substance),
            data.value(for: .hydroxide),
            data.value(for: .secondaryIon),
            data.value(for: .hydrogen)
        ]
    }()

    lazy var barChartDataMap: EnumMap<ExtendedSubstancePart, BarChartData> =
        .init {
            switch $0 {
            case .hydrogen: return BarChartData(
                label: PrimaryIon.hydrogen.chargedSymbol.text,
                equation: hydrogenBarEquation,
                color: RGB.hydrogen.color,
                accessibilityLabel: ""
            )
            case .hydroxide: return BarChartData(
                label: PrimaryIon.hydroxide.chargedSymbol.text,
                equation: hydroxideBarEquation,
                color: RGB.hydroxide.color,
                accessibilityLabel: ""
            )
            case .secondaryIon: return BarChartData(
                label: substance.chargedSymbol(ofPart: .secondaryIon).text,
                equation: ionBarChartEquation,
                color: substance.color(ofPart: .secondaryIon),
                accessibilityLabel: ""
            )
            case .substance: return BarChartData(
                label: substance.chargedSymbol(ofPart: .substance).text,
                equation: substanceBarChartEquation,
                color: substance.color,
                accessibilityLabel: ""
            )
            }
        }

    private var hydrogenBarEquation: Equation {
        if substance.type.isAcid {
            return ionBarChartEquation
        }
        return ConstantEquation(value: 0)
    }

    private var hydroxideBarEquation: Equation {
        if substance.type.isAcid {
            return ConstantEquation(value: 0)
        }
        return ionBarChartEquation
    }

    private lazy var ionBarChartEquation =
        LinearEquation(
            x1: 0,
            y1: 0,
            x2: 1,
            y2: changeInBarHeight
        )

    private lazy var substanceBarChartEquation =
        LinearEquation(
            x1: 0,
            y1: initialSubstanceConcentration,
            x2: 1,
            y2: initialSubstanceConcentration - changeInBarHeight
        )

    private lazy var changeInBarHeight =
        initialSubstanceConcentration * settings.weakIonChangeInBarHeightFraction
}

// MARK: - Input limits
extension TitrationWeakSubstancePreparationModel  {

    /// Maximum number of substance molecules which can be added.
    ///
    /// # Derivation
    ///
    /// Say we add N molecules. Then, when adding titrant we will add a further
    /// N molecules to react with the substance, and we'll have 2N secondary
    /// ion molecules in the beaker.
    ///
    /// In the final stage, we want to end up with an equal number of secondary
    /// ion and primary ion molecules. So, we add 2N primary ion molecules.
    ///
    /// The total we've added therefore is 4N molecules, which must be less than
    /// the grid size
    var maxSubstance: Int {
        Int(ceil(gridSizeFloat / 4))
    }

    var canAddSubstance: Bool {
        remainingCountAvailable > 0
    }

    var hasAddedEnoughSubstance: Bool {
        substanceAdded >= minSubstance
    }

    /// Minimum number of substance molecules which must be added.
    var minSubstance: Int {
        Int(ceil(settings.minInitialWeakConcentration * gridSizeFloat))
    }


    private var remainingCountAvailable: Int {
        max(0, maxSubstance - substanceAdded)
    }
}

// MARK: Initial reaction progress model
extension TitrationWeakSubstancePreparationModel {
    static func initialReactionProgress(
        substance: AcidOrBase,
        maxMolecules: Int
    ) -> ReactionProgressChartViewModel<ExtendedSubstancePart> {
        .init(
            molecules: .init {
                switch $0 {
                case .substance: return .init(
                    label: substance.chargedSymbol(ofPart: .substance).text,
                    columnIndex: 0,
                    initialCount: 0,
                    color: substance.color(ofPart: .substance)
                )
                case .hydroxide: return .init(
                    label: "OH^-^",
                    columnIndex: 1,
                    initialCount: 0,
                    color: RGB.hydroxide.color
                )
                case .secondaryIon: return .init(
                    label: substance.chargedSymbol(ofPart: .secondaryIon).text,
                    columnIndex: 2,
                    initialCount: 0,
                    color: substance.color(ofPart: .secondaryIon)
                )

                case .hydrogen: return .init(
                    label: "H^+^",
                    columnIndex: 3,
                    initialCount: 0,
                    color: RGB.hydrogen.color
                )
                }
            },
            settings: .init(maxMolecules: maxMolecules),
            timing: .init()
        )
    }
}
