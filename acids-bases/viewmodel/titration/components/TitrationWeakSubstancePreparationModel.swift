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
            case .hydrogen: return phFromConcentration(.hydrogen)
            case .hydroxide: return phFromConcentration(.hydroxide)
            case .kA: return substance.pKA
            case .kB: return substance.pKB
            }
        }
    }

    private func phFromConcentration(_ term: TitrationEquationTerm.Concentration) -> CGFloat {
        -1 * safeLog10(concentration.value(for: term).getY(at: reactionProgress))
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
    var maxSubstance: Int {
        25
    }
}
