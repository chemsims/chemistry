//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationWeakSubstancePreparationModel: ObservableObject {
    init(
        substance: AcidOrBase,
        cols: Int,
        rows: Int,
        settings: TitrationSettings
    ) {
        self.substance = substance
        self.cols = cols
        self.rows = rows
        self.settings = settings
        self.substanceCoords = BeakerMolecules(
            coords: [],
            color: substance.color,
            label: substance.symbol
        )
    }

    let substance: AcidOrBase
    let cols: Int
    var rows: Int
    let settings: TitrationSettings

    @Published var substanceCoords: BeakerMolecules
    @Published var reactionProgress: CGFloat = 0
    @Published var substanceAdded = 0

    private var gridSizeFloat: CGFloat {
        CGFloat(cols * rows)
    }
}

// MARK: Incrementing
extension TitrationWeakSubstancePreparationModel {
    func incrementSubstance(count: Int) {
        guard substanceAdded < maxSubstance else {
            return
        }
        substanceCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: substanceCoords.coords,
            count: count,
            cols: cols,
            rows: rows
        )
        withAnimation(.linear(duration: 1)) {
            substanceAdded += count
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
            case .hydrogen: return ionConcentration
            case .hydroxide: return ConstantEquation(value: 0)
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
}

// MARK: - P Values
extension TitrationWeakSubstancePreparationModel {
    var pValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return pHEquation.getY(at: 1)
            case .hydroxide: return 14 - pHEquation.getY(at: 1)
            case .kA: return substance.pKA
            case .kB: return substance.pKB
            }
        }
    }

    private var pHEquation: Equation {
        let secondaryC = concentration.value(for: .secondary)
        let substanceC = concentration.value(for: .substance)

        return substance.pKA + Log10Equation(underlying: secondaryC / substanceC)
    }
}

// MARK: - Molarity
extension TitrationWeakSubstancePreparationModel {
    var molarity: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        .constant(0)
    }
}

// MARK: - Bar chart
extension TitrationWeakSubstancePreparationModel {
    var barChartData: [BarChartData] {
        let data = extendedBarChartData
        return [
            data.value(for: .substance),
            data.value(for: .hydroxide),
            data.value(for: .secondaryIon),
            data.value(for: .hydrogen)
        ]
    }

    var extendedBarChartData: EnumMap<ExtendedSubstancePart, BarChartData> {
        .init {
            switch $0 {
            case .hydrogen: return BarChartData(
                label: PrimaryIon.hydrogen.rawValue,
                equation: ionBarChartEquation,
                color: RGB.hydrogen.color,
                accessibilityLabel: ""
            )
            case .hydroxide: return BarChartData(
                label: PrimaryIon.hydroxide.rawValue,
                equation: ConstantEquation(value: 0),
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
    var maxSubstance: Int {
        25
    }
}
