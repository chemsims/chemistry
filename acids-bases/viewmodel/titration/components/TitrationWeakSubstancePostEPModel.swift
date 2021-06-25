//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationWeakSubstancePostEPModel: ObservableObject {
    init(previous: TitrationWeakSubstancePreEPModel) {
        self.previous = previous
    }

    let previous: TitrationWeakSubstancePreEPModel

    @Published var titrantAdded = 0

    var settings: TitrationSettings {
        previous.settings
    }

    var substance: AcidOrBase {
        previous.substance
    }
}

// MARK: - Equation data
extension TitrationWeakSubstancePostEPModel {
    var equationData: TitrationEquationData {
        TitrationEquationData(
            substance: substance,
            titrant: "KOH",
            moles: moles,
            volume: volume,
            molarity: molarity.map { ConstantEquation(value: $0) },
            concentration: concentration
        )
    }
}

// MARK: - Incrementing
extension TitrationWeakSubstancePostEPModel {
    func incrementTitrant(count: Int) {
        guard titrantAdded < maxTitrant else {
            return
        }
        withAnimation(.linear(duration: 1)) {
            titrantAdded += count
        }
    }
}

// MARK: - Concentration
extension TitrationWeakSubstancePostEPModel {
    var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> {
        .init {
            switch $0 {
            case .hydrogen: return hydrogenConcentration
            case .hydroxide: return hydroxideConcentration
            case .secondary, .initialSecondary:
                return ConstantEquation(value: initialConcentration(of: .secondary))
            case .substance, .initialSubstance:
                return ConstantEquation(value: initialConcentration(of: .substance))
            }
        }
    }

    private var hydrogenConcentration: Equation {
        if !substance.type.isAcid {
            return LinearEquation(
                x1: 0,
                y1: initialConcentration(of: .hydrogen),
                x2: CGFloat(maxTitrant),
                y2: finalHConcentration
            )
        }
        return hydroxideConcentration.map(PrimaryIonConcentration.complementConcentration)
    }

    private var hydroxideConcentration: Equation {
        if !substance.type.isAcid {
            return hydrogenConcentration.map(PrimaryIonConcentration.complementConcentration)
        }
        return LinearEquation(
            x1: 0,
            y1: initialConcentration(of: .hydroxide),
            x2: CGFloat(maxTitrant),
            y2: finalOHConcentration
        )
    }

    private var finalHConcentration: CGFloat {
        PrimaryIonConcentration.concentration(forP: finalPH)
    }

    private var finalOHConcentration: CGFloat {
        let finalPOH = 14 - finalPH
        return PrimaryIonConcentration.concentration(forP: finalPOH)
    }

    private func initialConcentration(of part: TitrationEquationTerm.Concentration) -> CGFloat {
        previous.concentration.value(for: part).getY(at: CGFloat(previous.maxTitrant))
    }
}

// MARK: - P Values
extension TitrationWeakSubstancePostEPModel {
    var pValues: EnumMap<TitrationEquationTerm.PValue, Equation> {
        equationData.pValues
//        .init {
//            switch $0 {
//            case .hydrogen:
//                return -1 * Log10Equation(underlying: concentration.value(for: .hydrogen))
//            case .hydroxide:
//                return -1 * Log10Equation(underlying: concentration.value(for: .hydroxide))
//            case .kA: return ConstantEquation(value: substance.pKA)
//            case .kB: return ConstantEquation(value: substance.kB)
//            }
//        }
    }

    var pH: Equation {
        pValues.value(for: .hydrogen)
    }

    private var finalPH: CGFloat {
        if substance.type.isAcid {
            return settings.finalMaxPValue
        }
        return 14 - settings.finalMaxPValue
    }

    private var finalPOH: CGFloat {
        14 - finalPH
    }
}

// MARK: - Volume
extension TitrationWeakSubstancePostEPModel {
    var volume: EnumMap<TitrationEquationTerm.Volume, Equation> {
        .init {
            switch $0 {
            case .equivalencePoint: return ConstantEquation(value: epVolume)
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: 0)
            case .substance: return ConstantEquation(value: 0)
            case .titrant:
                return LinearEquation(
                    x1: 0,
                    y1: 0,
                    x2: CGFloat(maxTitrant),
                    y2: finalTitrantVolume
                )
            }
        }
    }

    // Titrant volume which satisfies the equation:
    // [OH] = n-titrant / (V-e + V-koh)
    // Rearranging & substituting n-titrant = V-koh * M-koh, we get:
    // V-koh = ([OH]Ve)/(M-koh - OH)
    private var finalTitrantVolume: CGFloat {
        let finalOh = finalOHConcentration
        let numer = finalOh * epVolume
        let denom = titrantMolarity - finalOh
        return denom == 0 ? 0 : numer / denom
    }

    private var epVolume: CGFloat {
        initialVolume(of: .titrant) + initialVolume(of: .initialSubstance)
    }

    private func initialVolume(of term: TitrationEquationTerm.Volume) -> CGFloat {
        previous.volume.value(for: term).getY(at: CGFloat(previous.maxTitrant))
    }
}

// MARK: Moles
extension TitrationWeakSubstancePostEPModel {
    var moles: EnumMap<TitrationEquationTerm.Moles, Equation> {
        .init {
            switch $0 {
            case .titrant: return titrantMolarity * volume.value(for: .titrant)
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: 0)
            case .secondary: return ConstantEquation(value: 0)
            case .substance: return ConstantEquation(value: 0)
            }
        }
    }
}

// MARK: Molarity
extension TitrationWeakSubstancePostEPModel {

    var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .substance: return previous.equationData.molarity.value(for: .substance).getY(at: CGFloat(previous.titrantAdded))
            case .titrant: return titrantMolarity
            }
        }
    }

    var titrantMolarity: CGFloat {
        previous.titrantMolarity
    }
}

// MARK: Bar chart data
extension TitrationWeakSubstancePostEPModel {

    var barChartData: [BarChartData] {
        let order: [ExtendedSubstancePart] = [.substance, .hydroxide, .hydrogen, .secondaryIon]
        return order.map(barChartDataMap.value)
    }

    var barChartDataMap: EnumMap<ExtendedSubstancePart, BarChartData> {
        .init {
            switch $0 {
            case .hydrogen: return BarChartData(
                label: PrimaryIon.hydrogen.rawValue,
                equation: barChartEquation(forPart: .hydrogen),
                color: RGB.hydrogen.color,
                accessibilityLabel: ""
            )
            case .hydroxide: return BarChartData(
                label: PrimaryIon.hydroxide.rawValue,
                equation: barChartEquation(forPart: .hydroxide),
                color: RGB.hydroxide.color,
                accessibilityLabel: ""
            )
            case .secondaryIon: return BarChartData(
                label: substance.symbol(ofPart: .secondaryIon),
                equation: barChartEquation(forPart: .secondaryIon),
                color: substance.color(ofPart: .secondaryIon),
                accessibilityLabel: ""
            )
            case .substance: return BarChartData(
                label: substance.symbol,
                equation: barChartEquation(forPart: .substance),
                color: substance.color(ofPart: .substance),
                accessibilityLabel: ""
            )
            }
        }
    }

    private func barChartEquation(forPart part: ExtendedSubstancePart) -> Equation {
        LinearEquation(
            x1: 0,
            y1: initialBarHeight(forPart: part),
            x2: CGFloat(maxTitrant),
            y2: concentration
                .value(for: concentrationFromPart(part))
                .getY(at: CGFloat(maxTitrant))
        )
    }

    private func concentrationFromPart(_ part: ExtendedSubstancePart) -> TitrationEquationTerm.Concentration {
        switch part {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        case .secondaryIon: return .secondary
        case .substance: return .substance
        }
    }

    private func initialBarHeight(forPart part: ExtendedSubstancePart) -> CGFloat {
        previous.barChartDataMap.value(for: part).equation.getY(at: CGFloat(previous.maxTitrant))
    }
}

// MARK: - Input limits
extension TitrationWeakSubstancePostEPModel {
    var maxTitrant: Int {
        25
    }
}
