//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationStrongSubstancePostEPModel: ObservableObject {

    init(
        previous: TitrationStrongSubstancePreEPModel
    ) {
        self.previous = previous
        self.titrantMolecules = BeakerMolecules(
            coords: [],
            color: .purple,
            label: ""
        )
    }

    let previous: TitrationStrongSubstancePreEPModel
    @Published var titrantAdded = 0
    @Published var titrantMolecules: BeakerMolecules

    var settings: TitrationSettings {
        previous.settings
    }

    var substance: AcidOrBase {
        previous.substance
    }
}

// MARK: - Incrementing titrant
extension TitrationStrongSubstancePostEPModel {
    func incrementTitrant(count: Int) {
        guard titrantAdded < maxTitrant else {
            return
        }
        titrantMolecules.coords = GridCoordinateList.addingRandomElementsTo(
            grid: titrantMolecules.coords,
            count: count,
            cols: previous.previous.cols,
            rows: previous.previous.rows
        )
        withAnimation(.linear(duration: 1)) {
            titrantAdded += count
        }
    }
}

// MARK: - Concentration
extension TitrationStrongSubstancePostEPModel {
    var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> {
        .init {
            switch $0 {
            case .hydrogen: return hConcentration
            case .hydroxide: return ohConcentration
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: 0)
            case .secondary: return ConstantEquation(value: 0)
            case .substance: return ConstantEquation(value: 0)
            }
        }
    }

    private var hConcentration: Equation {
        if substance.type.isAcid {
            return primaryIonConcentration
        }
        return complementPrimaryIonConcentration
    }

    private var ohConcentration: Equation {
        if substance.type.isAcid {
            return complementPrimaryIonConcentration
        }
        return primaryIonConcentration
    }

    private var primaryIonConcentration: Equation {
        complementPrimaryIonConcentration.map(PrimaryIonConcentration.complementConcentration)
    }

    private var complementPrimaryIonConcentration: Equation {
        LinearEquation(
            x1: 0,
            y1: 1e-7,
            x2: CGFloat(maxTitrant),
            y2: finalComplementPrimaryIonConcentration
        )
    }

    private var finalPrimaryIonConcentration: CGFloat {
        PrimaryIonConcentration.concentration(forP: finalComplementPrimaryIonPValue)
    }

    var finalComplementPrimaryIonConcentration: CGFloat {
        PrimaryIonConcentration.concentration(forP: finalComplementPrimaryIonPValue)
    }
}

// MARK: - P Values
extension TitrationStrongSubstancePostEPModel {

    var pValues: EnumMap<TitrationEquationTerm.PValue, Equation> {
        equationData.pValues
//        .init {
//            switch $0 {
//            case .hydrogen:
//                return -1 * Log10Equation(underlying: concentration.value(for: .hydrogen))
//            case .hydroxide:
//                return -1 * Log10Equation(underlying: concentration.value(for: .hydroxide))
//            case .kA: return ConstantEquation(value: previous.substance.pKA)
//            case .kB: return ConstantEquation(value: previous.substance.pKB)
//            }
//        }
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

    /// The p__ value of the complement to the primary ion at the end of the reaction.
    ///
    /// For example, for an acid substance, this would be pOH.
    private var finalComplementPrimaryIonPValue: CGFloat {
        substance.type.isAcid ? finalPOH : finalPH
    }

    var pH: Equation {
        pValues.value(for: .hydrogen)
    }
}

// MARK: - Bar chart data
extension TitrationStrongSubstancePostEPModel {
    var barChartData: [BarChartData] {
        let map = barChartDataMap
        return [map.value(for: .hydroxide), map.value(for: .hydrogen)]
    }

    var barChartDataMap: EnumMap<PrimaryIon, BarChartData> {
        .init(builder: barChartData)
    }

    private func barChartData(forIon primaryIon: PrimaryIon) -> BarChartData {
        BarChartData(
            label: primaryIon.rawValue,
            equation: barChartEquation(forIon: primaryIon),
            color: primaryIon.color,
            accessibilityLabel: ""
        )
    }

    private func barChartEquation(forIon primaryIon: PrimaryIon) -> Equation {
        if substance.primary == primaryIon {
            return decreasingBarChartEquation
        }
        return increasingBarChartEquation
    }

    private var increasingBarChartEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: settings.neutralSubstanceBarChartHeight,
            x2: CGFloat(maxTitrant),
            y2: settings
                .barChartHeightFromConcentration
                .getY(at: increasingIonConcentration.getY(at: CGFloat(maxTitrant)))
        )
    }

    var increasingIonConcentration: Equation {
        if substance.type.isAcid {
            return ohConcentration
        }
        return hConcentration
    }

    private var decreasingBarChartEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: settings.neutralSubstanceBarChartHeight,
            x2: CGFloat(maxTitrant),
            y2: 0
        )
    }
}

// MARK: - Equation data
extension TitrationStrongSubstancePostEPModel {

    var equationData: TitrationEquationData {
        TitrationEquationData(
            substance: previous.previous.substance,
            titrant: previous.previous.titrant,
            moles: moles.map(ConstantEquation.init),
            volume: volume.map(ConstantEquation.init),
            molarity: molarity.map(ConstantEquation.init),
            concentration: concentration
        )
    }

    var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        previous.molarity
    }

    var moles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .initialSecondary: return 0
            case .initialSubstance: return previous.moles.value(for: .initialSubstance)
            case .secondary: return 0
            case .substance: return previous.moles.value(for: .substance)
            case .titrant: return titrantMoles
            }
        }
    }

    var volume: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
        .init {
            switch $0 {
            case .equivalencePoint: return 0
            case .hydrogen: return 0
            case .initialSecondary: return 0
            case .initialSubstance: return 0
            case .substance: return previous.previous.currentVolume
            case .titrant: return titrantVolume.getY(at: CGFloat(titrantAdded))
            }
        }
    }



    var titrantMoles: CGFloat {
        volume.value(for: .titrant) * previous.molarity.value(for: .titrant)
    }

    /// Returns final titrant moles to satisfy the equation (for a strong acid HCl with a titrant KOH):
    /// [OH] = (nkoh - nhcl) / (Vhcl + Vkoh)
    /// using the relation nkoh = Vkoh * Mkph
    var finalTitrantMoles: CGFloat {
        let titrantMolarity = previous.molarity.value(for: .titrant)
        let numer1 = finalComplementPrimaryIonConcentration * previous.previous.currentVolume * titrantMolarity
        let numer2 = previous.moles.value(for: .substance) * titrantMolarity
        let numerator = numer1 + numer2
        let denominator = titrantMolarity - finalComplementPrimaryIonConcentration

        return denominator == 0 ? 0 : numerator / denominator
    }

    var finalTitrantVolume: CGFloat {
        finalTitrantMoles / previous.molarity.value(for: .titrant)
    }

    var initialTitrantVolume: CGFloat {
        previous.volume.value(for: .titrant)
    }

    var titrantVolume: Equation {
        LinearEquation(
            x1: 0,
            y1: initialTitrantVolume,
            x2: CGFloat(maxTitrant),
            y2: finalTitrantVolume
        )
    }

    var currentOh: CGFloat {
        ohConcentration.getY(at: CGFloat(maxTitrant))
    }
}

// MARK: - Input limits
extension TitrationStrongSubstancePostEPModel {
    var maxTitrant: Int {
        20
    }
}
