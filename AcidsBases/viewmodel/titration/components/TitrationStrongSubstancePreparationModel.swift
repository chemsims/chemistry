//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationStrongSubstancePreparationModel: ObservableObject {

    init(
        substance: AcidOrBase,
        titrant: Titrant,
        cols: Int,
        rows: Int,
        settings: TitrationSettings,
        maxReactionProgressMolecules: Int = AcidAppSettings.maxReactionProgressMolecules
    ) {
        let initialTitrantMolarity = AcidAppSettings.initialTitrantMolarity
        self.titrantMolarity = initialTitrantMolarity
        self.substance = substance
        self.cols = cols
        self.exactRows = CGFloat(rows)
        self.settings = settings
        self.titrant = titrant

        self.primaryIonCoords = BeakerMolecules(
            coords: [],
            color: substance.primary.color,
            label: substance.accessibilityLabel(ofPart: .primaryIon)
        )
        self.reactionProgress = ReactionProgressChartViewModel(
            molecules: .init {
                switch $0 {
                case .hydrogen: return .init(
                    label: "H^+^",
                    columnIndex: 0,
                    initialCount: 0,
                    color: RGB.hydrogen.color
                )
                case .hydroxide: return .init(
                    label: "OH^-^",
                    columnIndex: 1,
                    initialCount: 0,
                    color: RGB.hydroxide.color
                )
                }
            },
            settings: .init(maxMolecules: maxReactionProgressMolecules),
            timing: .init()
        )

        self.calculations = Calculations(
            substance: substance,
            titrant: titrant,
            gridSizeFloat: CGFloat(cols * rows),
            exactRows: CGFloat(rows),
            settings: settings,
            titrantMolarity: initialTitrantMolarity
        )
    }

    var substance: AcidOrBase {
        didSet {
            updateCalculations()
        }
    }
    let titrant: Titrant
    let cols: Int
    @Published var exactRows: CGFloat {
        didSet {
            updateCalculations()
        }
    }
    let settings: TitrationSettings

    @Published var primaryIonCoords: BeakerMolecules
    @Published var substanceAdded: Int = 0

    @Published var titrantMolarity: CGFloat {
        didSet {
            updateCalculations()
        }
    }

    @Published var reactionProgress: ReactionProgressChartViewModel<PrimaryIon>

    var rows: Int {
        GridCoordinateList.availableRows(for: exactRows)
    }

    private var gridSizeFloat: CGFloat {
        CGFloat(cols * rows)
    }

    /// Returns a distinct instance of the reaction progress view model.
    func copyReactionProgress() -> ReactionProgressChartViewModel<PrimaryIon> {
        let original = reactionProgress
        self.reactionProgress = reactionProgress.copy()
        return original
    }

    private var calculations: Calculations
}

// MARK: Incrementing
extension TitrationStrongSubstancePreparationModel {
    func incrementSubstance(count: Int) {
        let maxToAdd = min(count, remainingCountAvailable)
        guard maxToAdd > 0 else {
            return
        }
        primaryIonCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: primaryIonCoords.coords,
            count: maxToAdd,
            cols: cols,
            rows: rows
        )
        withAnimation(.linear(duration: 1)) {
            substanceAdded += maxToAdd
        }
        updateReactionProgress()
    }
}

// MARK: - Reaction progress
extension TitrationStrongSubstancePreparationModel {
    private func updateReactionProgress() {
        let desiredCount = primaryMoleculesFromSubstance.getValue(at: CGFloat(substanceAdded)).roundedInt()
        let currentCount = reactionProgress.moleculeCounts(ofType: substance.primary)
        let delta = desiredCount - currentCount

        assert(delta >= 0, "Delta should not be negative")
        if delta > 0 {
            (0..<delta).forEach { _ in
                _ = reactionProgress.addMolecule(substance.primary)
            }
        }
    }

    private var primaryMoleculesFromSubstance: Equation {
        LinearEquation(
            x1: 0,
            y1: 0,
            x2: CGFloat(calculations.maxSubstance),
            y2: CGFloat(reactionProgress.settings.maxMolecules)
        )
    }
}

// MARK - Calculation access
extension TitrationStrongSubstancePreparationModel {
    func updateCalculations() {
        self.calculations = .init(
            substance: substance,
            titrant: titrant,
            gridSizeFloat: gridSizeFloat,
            exactRows: exactRows,
            settings: settings,
            titrantMolarity: titrantMolarity
        )
    }

    var equationData: TitrationEquationData {
        calculations.equationData
    }

    var barChartData: [BarChartData] {
        calculations.barChartData
    }

    var barChartDataMap: EnumMap<PrimaryIon, BarChartData> {
        calculations.barChartDataMap
    }

    var currentConcentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        calculations.concentration.map { $0.getValue(at: CGFloat(substanceAdded)) }
    }

    var currentMoles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        calculations.moles.map { $0.getValue(at: CGFloat(substanceAdded)) }
    }

    var currentMolarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        calculations.molarity.map { $0.getValue(at: CGFloat(substanceAdded)) }
    }

    var currentVolume: CGFloat {
        calculations.currentVolume
    }

    var barChartHeightEquation: PrimaryIonValue<Equation> {
        calculations.barChartHeightEquation
    }
}

// MARK: - Input limits
extension TitrationStrongSubstancePreparationModel {

    var canAddSubstance: Bool {
        remainingCountAvailable > 0
    }

    var hasAddedEnoughSubstance: Bool {
        substanceAdded >= minSubstance
    }

    /// Minimum substance count to ensure the `minInitialStrongConcentration` is met
    private var minSubstance: Int {
        Int(ceil((settings.minInitialStrongConcentration * gridSizeFloat)))
    }

    private var remainingCountAvailable: Int {
        max(0, maxSubstance - substanceAdded)
    }

    var maxSubstance: Int {
        calculations.maxSubstance
    }
}

// MARK: - Equation Data
private class Calculations {

    init(
        substance: AcidOrBase,
        titrant: Titrant,
        gridSizeFloat: CGFloat,
        exactRows: CGFloat,
        settings: TitrationSettings,
        titrantMolarity: CGFloat
    ) {
        self.substance = substance
        self.titrant = titrant
        self.gridSizeFloat = gridSizeFloat
        self.exactRows = exactRows
        self.settings = settings
        self.titrantMolarity = titrantMolarity
    }

    let substance: AcidOrBase
    let titrant: Titrant
    let gridSizeFloat: CGFloat
    let exactRows: CGFloat
    let settings: TitrationSettings
    let titrantMolarity: CGFloat

    lazy var equationData: TitrationEquationData =
        TitrationEquationData(
            substance: substance,
            titrant: titrant.name,
            moles: moles,
            volume: volume,
            molarity: molarity,
            concentration: concentration
        )

    // MARK: - Concentration

    /// Equation for concentration in terms of substance added
    lazy var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> =
        .init {
            switch $0 {
            case .hydrogen: return hydrogenConcentration
            case .hydroxide: return hydroxideConcentration
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: 0)
            case .secondary: return ConstantEquation(value: 0)
            case .substance: return ConstantEquation(value: 0)
            }
        }

    private lazy var hydrogenConcentration: Equation = {
        if substance.type.isAcid {
            return substanceConcentration
        }
        return complementaryIonConcentration
    }()

    private lazy var hydroxideConcentration: Equation = {
        if substance.type.isAcid {
            return complementaryIonConcentration
        }
        return substanceConcentration
    }()

    private lazy var substanceConcentration =
        LinearEquation(
            x1: 0,
            y1: 1e-7,
            x2: CGFloat(maxSubstance),
            y2: CGFloat(maxSubstance) / gridSizeFloat
        )

    private lazy var complementaryIonConcentration: Equation =
        substanceConcentration.map(PrimaryIonConcentration.complementConcentration)

    // MARK: - Bar chart
    var barChartData: [BarChartData] {
        let map = barChartDataMap
        return [map.hydroxide, map.hydrogen]
    }

    var barChartDataMap: EnumMap<PrimaryIon, BarChartData> {
        .init(builder: barChartData)
    }

    private func barChartData(forIon primaryIon: PrimaryIon) -> BarChartData {
        BarChartData(
            label: primaryIon.chargedSymbol.text,
            equation: barChartHeightEquation.value(for: primaryIon),
            color: primaryIon.color,
            accessibilityLabel: primaryIon.accessibilityLabel
        )
    }

    var barChartHeightEquation: PrimaryIonValue<Equation> {
        PrimaryIonValue(
            hydrogen: substance.primary == .hydrogen ? increasingBarEquation : decreasingBarEquation,
            hydroxide: substance.primary == .hydroxide ? increasingBarEquation : decreasingBarEquation
        )
    }

    private var increasingBarEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: settings.neutralSubstanceBarChartHeight,
            x2: CGFloat(maxSubstance),
            y2: settings
                .barChartHeightFromConcentration
                .getValue(
                    at: substanceConcentration.getValue(at: CGFloat(maxSubstance))
                )
        )
    }

    private var decreasingBarEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: settings.neutralSubstanceBarChartHeight,
            x2: CGFloat(maxSubstance),
            y2: 0
        )
    }


    // MARK: - Moles

    lazy var moles: EnumMap<TitrationEquationTerm.Moles, Equation> =
        .init {
            switch $0 {
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .secondary: return ConstantEquation(value: 0)
            case .titrant: return ConstantEquation(value: 0)
            case .initialSubstance:
                return molarity.value(for: .substance) * volume.value(for: .substance)
            case .substance:
                return molarity.value(for: .substance) * volume.value(for: .substance)

            }
        }

    // MARK: - Molarity

    lazy var molarity: EnumMap<TitrationEquationTerm.Molarity, Equation> =
        .init {
            switch $0 {
            case .hydrogen: return ConstantEquation(value: 0)
            case .substance: return substanceConcentration
            case .titrant: return ConstantEquation(value: titrantMolarity)
            }
        }


    // MARK: - Volume

    lazy var volume: EnumMap<TitrationEquationTerm.Volume, Equation> =
        .init {
            switch $0 {
            case .equivalencePoint: return ConstantEquation(value: 0)
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: currentVolume)
            case .substance: return ConstantEquation(value: currentVolume)
            case .titrant: return ConstantEquation(value: 0)
            }
        }

    var currentVolume: CGFloat {
        settings.beakerVolumeFromRows.getValue(at: exactRows)
    }
 
    /// Maximum substance count to ensure the `maxInitialStrongConcentration` is not exceeded.
    var maxSubstance: Int {
        Int(settings.maxInitialStrongConcentration * gridSizeFloat)
    }
}
