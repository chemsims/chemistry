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
            color: previous.previous.titrant.maximumMolarityColor.color,
            label: ""
        )
        self.maxTitrant = previous.maxTitrant
    }

    let previous: TitrationStrongSubstancePreEPModel
    @Published var titrantAdded = 0
    @Published var titrantMolecules: BeakerMolecules

    let maxTitrant: Int

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
        let maxToAdd = min(remainingCountAvailable, count)
        guard maxToAdd > 0 else {
            return
        }
        titrantMolecules.coords = GridCoordinateList.addingRandomElementsTo(
            grid: titrantMolecules.coords,
            count: maxToAdd,
            cols: previous.previous.cols,
            rows: previous.previous.rows
        )
        withAnimation(.linear(duration: 1)) {
            titrantAdded += maxToAdd
        }
    }
}

// MARK: - Equation data
extension TitrationStrongSubstancePostEPModel {
    var equationData: TitrationEquationData {
        TitrationEquationData(
            substance: previous.previous.substance,
            titrant: previous.previous.titrant.name,
            moles: moles,
            volume: volume,
            molarity: molarity.map(ConstantEquation.init),
            concentration: concentration
        )
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

    private var finalComplementPrimaryIonConcentration: CGFloat {
        PrimaryIonConcentration.concentration(forP: finalComplementPrimaryIonPValue)
    }
}

// MARK: - P Values
extension TitrationStrongSubstancePostEPModel {

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
        equationData.pValues.value(for: .hydrogen)
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

// MARK: - Molarity
extension TitrationStrongSubstancePostEPModel {

    var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        previous.molarity
    }
}

// MARK: - Moles
extension TitrationStrongSubstancePostEPModel {

    var moles: EnumMap<TitrationEquationTerm.Moles, Equation> {
        .init {
            switch $0 {
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: previous.currentMoles.value(for: .initialSubstance))
            case .secondary: return ConstantEquation(value: 0)
            case .substance: return ConstantEquation(value: previous.currentMoles.value(for: .substance))
            case .titrant: return titrantMoles
            }
        }
    }

    var titrantMoles: Equation {
        volume.value(for: .titrant) * ConstantEquation(value: previous.molarity.value(for: .titrant))
    }

    /// Returns final titrant moles to satisfy the equation (for a strong acid HCl with a titrant KOH):
    /// [OH] = (nkoh - nhcl) / (Vhcl + Vkoh)
    /// using the relation nkoh = Vkoh * Mkph
    var finalTitrantMoles: CGFloat {
        let titrantMolarity = previous.molarity.value(for: .titrant)
        let numer1 = finalComplementPrimaryIonConcentration * previous.previous.currentVolume * titrantMolarity
        let numer2 = previous.currentMoles.value(for: .substance) * titrantMolarity
        let numerator = numer1 + numer2
        let denominator = titrantMolarity - finalComplementPrimaryIonConcentration

        return denominator == 0 ? 0 : numerator / denominator
    }
}

// MARK: - Volume
extension TitrationStrongSubstancePostEPModel {

    var volume: EnumMap<TitrationEquationTerm.Volume, Equation> {
        .init {
            switch $0 {
            case .equivalencePoint: return ConstantEquation(value: 0)
            case .hydrogen: return ConstantEquation(value: 0)
            case .initialSecondary: return ConstantEquation(value: 0)
            case .initialSubstance: return ConstantEquation(value: 0)
            case .substance: return ConstantEquation(value: previous.previous.currentVolume)
            case .titrant: return titrantVolume
            }
        }
    }

    var finalTitrantVolume: CGFloat {
        finalTitrantMoles / previous.molarity.value(for: .titrant)
    }

    var initialTitrantVolume: CGFloat {
        previous.currentVolume.value(for: .titrant)
    }

    var titrantVolume: Equation {
        LinearEquation(
            x1: 0,
            y1: initialTitrantVolume,
            x2: CGFloat(maxTitrant),
            y2: finalTitrantVolume
        )
    }
}

// MARK: - Input limits
extension TitrationStrongSubstancePostEPModel {
    var canAddTitrant: Bool {
        remainingCountAvailable > 0
    }

    var hasAddedEnoughTitrant: Bool {
        !canAddTitrant
    }

    private var remainingCountAvailable: Int {
        max(0, maxTitrant - titrantAdded)
    }
}
