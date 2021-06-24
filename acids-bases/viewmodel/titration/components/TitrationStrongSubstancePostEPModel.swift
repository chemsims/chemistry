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
            moles: moles,
            volume: volume,
            molarity: molarity,
            concentration: concentration,
            pValues: pValues,
            kValues: kValues
        )
    }

    var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        previous.molarity
    }

    var kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat> {
        previous.kValues
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

    var concentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return hConcentration.getY(at: CGFloat(titrantAdded))
            case .hydroxide: return ohConcentration.getY(at: CGFloat(titrantAdded))
            case .initialSecondary: return 0
            case .initialSubstance: return 0
            case .secondary: return 0
            case .substance: return 0
            }
        }
    }

    var pValues: EnumMap<TitrationEquationTerm.PValue, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return -safeLog10(concentration.value(for: .hydrogen))
            case .hydroxide: return -safeLog10(concentration.value(for: .hydroxide))
            case .kA: return previous.substance.pKA
            case .kB: return previous.substance.pKB
            }
        }
    }

    var titrantMoles: CGFloat {
        volume.value(for: .titrant) * previous.molarity.value(for: .titrant)
    }

    var hConcentration: LinearEquation {
        if substance.type.isAcid {
            return LinearEquation(
                x1: 0,
                y1: 1e-7,
                x2: CGFloat(maxTitrant),
                y2: finalHConcentration
            )
        }
        return LinearEquation(
            x1: 0,
            y1: 1e-7,
            x2: CGFloat(maxTitrant),
            y2: finalOH
        )
    }

    /// Returns final titrant moles to satisfy the equation:
    /// [OH] = (nkoh - nhcl) / (Vhcl + Vkoh)
    /// using the relation nkoh = Vkoh * Mkph
    var finalTitrantMoles: CGFloat {
        let titrantMolarity = previous.molarity.value(for: .titrant)
        let numer1 = finalOH * previous.previous.currentVolume * titrantMolarity
        let numer2 = previous.moles.value(for: .substance) * titrantMolarity
        let numerator = numer1 + numer2
        let denominator = titrantMolarity - finalOH

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

    var ohConcentration: Equation {
        if substance.type.isAcid {
            return LinearEquation(
                x1: 0,
                y1: 1e-7,
                x2: CGFloat(maxTitrant),
                y2: finalOH
            )
        }
        return LinearEquation(
            x1: 0,
            y1: 1e-7,
            x2: CGFloat(maxTitrant),
            y2: finalHConcentration
        )
    }

    var finalOH: CGFloat {
        PrimaryIonConcentration.concentration(forP: finalPOH)
    }

    var finalPOH: CGFloat {
        14 - finalPh
    }

    var finalPh: CGFloat {
        settings.finalMaxPValue
    }

    var currentOh: CGFloat {
        ohConcentration.getY(at: CGFloat(maxTitrant))
    }

    var pH: Equation {
        14 + Log10Equation(underlying: ohConcentration)
    }



    var finalHConcentration: CGFloat {
        PrimaryIonConcentration.concentration(forP: finalPh)
    }
}

// MARK: - Input limits
extension TitrationStrongSubstancePostEPModel {
    var maxTitrant: Int {
        20
    }
}
