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
        settings: TitrationSettings
    ) {
        self.substance = substance
        self.titrant = titrant
        self.cols = cols
        self.exactRows = CGFloat(rows)
        self.settings = settings
        self.substanceCoords = BeakerMolecules(
            coords: [],
            color: substance.color,
            label: substance.symbol
        )
    }

    var substance: AcidOrBase
    let titrant: Titrant
    let cols: Int

    let settings: TitrationSettings

    @Published var exactRows: CGFloat

    @Published var substanceCoords: BeakerMolecules
    @Published var reactionProgress: CGFloat = 0
    @Published var substanceAdded = 0

    @Published var titrantMolarity = AcidAppSettings.initialTitrantMolarity

    private var gridSizeFloat: CGFloat {
        CGFloat(cols * rows)
    }

    var rows: Int {
        GridCoordinateList.availableRows(for: exactRows)
    }
}

// MARK: - Equation data
extension TitrationWeakSubstancePreparationModel {
    var equationData: TitrationEquationData {
        TitrationEquationData(
            substance: substance,
            titrant: "KOH", // TODO
            moles: moles,
            volume: volume.map { ConstantEquation(value: $0) },
            molarity: molarity.map { ConstantEquation(value: $0) },
            concentration: concentration
        )
    }

    var kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat> {
        .init {
            switch $0 {
            case .kA: return substance.kA
            case .kB: return substance.kB
            }
        }
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
    }
}

// MARK: - Concentration
extension TitrationWeakSubstancePreparationModel {
    var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> {
        .init {
            switch $0 {
            case .substance, .initialSubstance: return substanceConcentration
            case .secondary, .initialSecondary: return ionConcentration
            case .hydrogen: return hydrogenConcentration
            case .hydroxide: return hydroxideConcentration
            }
        }
    }

    private var substanceConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: initialSubstanceConcentration,
            x2: 1,
            y2: initialSubstanceConcentration - changeInConcentration
        )
    }

    private var ionConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: 0,
            x2: 1,
            y2: changeInConcentration
        )
    }

    private var complementPrimaryIonConcentration: Equation {
        ionConcentration.map(PrimaryIonConcentration.complementConcentration)
    }

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

    // TODO - might be worth making this not computed
    private var changeInConcentration: CGFloat {
        AcidConcentrationEquations.changeInConcentration(
            substance: substance,
            initialSubstanceConcentration: initialSubstanceConcentration
        )
    }

    private var initialSubstanceConcentration: CGFloat {
        CGFloat(substanceCoords.coords.count) / gridSizeFloat
    }

    var currentPH: CGFloat {
        equationData.pValues.value(for: .hydrogen).getY(at: reactionProgress)
    }
}

// MARK: - Volume
extension TitrationWeakSubstancePreparationModel {
    var volume: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
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
    }
}

// MARK: - Moles
extension TitrationWeakSubstancePreparationModel {
    var moles: EnumMap<TitrationEquationTerm.Moles, Equation> {
        .init {
            switch $0 {
            case .substance, .initialSubstance:
                return volume.value(for: .substance) * concentration.value(for: .substance)
            case .secondary, .initialSecondary:
                return volume.value(for: .substance) * concentration.value(for: .secondary)
            case .hydrogen: return ConstantEquation(value: 0)
            case .titrant: return ConstantEquation(value: 0)
            }
        }
    }

    var currentSubstanceMoles: CGFloat {
        moles.value(for: .substance).getY(at: reactionProgress)
    }
}

// MARK: - Molarity
extension TitrationWeakSubstancePreparationModel {
    var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return concentration.value(for: .hydrogen).getY(at: reactionProgress)
            case .substance: return concentration.value(for: .substance).getY(at: reactionProgress)
            case .titrant: return titrantMolarity
            }
        }
    }
}

// MARK: - Bar chart
extension TitrationWeakSubstancePreparationModel {
    var barChartData: [BarChartData] {
        let data = barChartDataMap
        return [
            data.value(for: .substance),
            data.value(for: .hydroxide),
            data.value(for: .secondaryIon),
            data.value(for: .hydrogen)
        ]
    }

    var barChartDataMap: EnumMap<ExtendedSubstancePart, BarChartData> {
        .init {
            switch $0 {
            case .hydrogen: return BarChartData(
                label: PrimaryIon.hydrogen.rawValue,
                equation: hydrogenBarEquation,
                color: RGB.hydrogen.color,
                accessibilityLabel: ""
            )
            case .hydroxide: return BarChartData(
                label: PrimaryIon.hydroxide.rawValue,
                equation: hydroxideBarEquation,
                color: RGB.hydroxide.color,
                accessibilityLabel: ""
            )
            case .secondaryIon: return BarChartData(
                label: substance.symbol(ofPart: .secondaryIon),
                equation: ionBarChartEquation,
                color: substance.color(ofPart: .secondaryIon),
                accessibilityLabel: ""
            )
            case .substance: return BarChartData(
                label: substance.symbol,
                equation: substanceBarChartEquation,
                color: substance.color,
                accessibilityLabel: ""
            )
            }
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

    private var ionBarChartEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: 0,
            x2: 1,
            y2: changeInBarHeight
        )
    }

    private var substanceBarChartEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: initialSubstanceConcentration,
            x2: 1,
            y2: initialSubstanceConcentration - changeInBarHeight
        )
    }

    private var changeInBarHeight: CGFloat {
        initialSubstanceConcentration * settings.weakIonChangeInBarHeightFraction
    }
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
