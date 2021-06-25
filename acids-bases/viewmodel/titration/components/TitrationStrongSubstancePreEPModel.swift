//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationStrongSubstancePreEPModel: ObservableObject {

    init(previous: TitrationStrongSubstancePreparationModel) {
        self.previous = previous
        let maxTitrant = 20
        self.maxTitrant = maxTitrant
        self.primaryIonCoords = AnimatingBeakerMolecules(
            molecules: previous.primaryIonCoords,
            fractionToDraw: LinearEquation(
                x1: 0,
                y1: 1,
                x2: CGFloat(maxTitrant),
                y2: 0
            )
        )
    }

    let previous: TitrationStrongSubstancePreparationModel
    @Published var titrantAdded: Int = 0
    let primaryIonCoords: AnimatingBeakerMolecules

    // MARK: Input Limits
    let maxTitrant: Int

    var substance: AcidOrBase {
        previous.substance
    }

    var settings: TitrationSettings {
        previous.settings
    }
}

// MARK: - Incrementing
extension TitrationStrongSubstancePreEPModel {
    func incrementTitrant(count: Int) {
        guard titrantAdded < maxTitrant else {
            return
        }
        withAnimation(.linear(duration: 1)) {
            titrantAdded += count
        }
    }
}

// MARK: - Titrant volume
extension TitrationStrongSubstancePreEPModel {
    var titrantVolumeAdded: Equation {
        LinearEquation(
            x1: 0,
            y1: 0,
            x2: CGFloat(maxTitrant),
            y2: finalTitrantVolume
        )
    }

    var currentTitrantVolume: CGFloat {
        titrantVolumeAdded.getY(at: CGFloat(titrantAdded))
    }
}

// MARK: - Bar chart data
extension TitrationStrongSubstancePreEPModel {
    var barChartData: [BarChartData] {
        let map = barChartDataMap
        return [map.value(for: .hydroxide), map.value(for: .hydrogen)]
    }

    var barChartDataMap: EnumMap<PrimaryIon, BarChartData> {
        .init(builder: barChartData)
    }

    private func barChartData(forIon primaryIon: PrimaryIon) -> BarChartData {
        BarChartData(
            label: primaryIon.rawValue, // TODO get the charged symbol
            equation: barChartEquation(forIon: primaryIon),
            color: primaryIon.color,
            accessibilityLabel: "" // TODO
        )
    }


    private func barChartEquation(forIon primaryIon: PrimaryIon) -> Equation {
        LinearEquation(
            x1: 0,
            y1: previous.barChartHeightEquation.value(for: primaryIon).getY(at: CGFloat(previous.substanceAdded)),
            x2: CGFloat(maxTitrant),
            y2: settings.neutralSubstanceBarChartHeight
        )
    }
}

// MARK: - Equation data
extension TitrationStrongSubstancePreEPModel {

    var equationData: TitrationEquationData {
        TitrationEquationData(
            substance: previous.substance,
            titrant: previous.titrant,
            moles: moles.map { ConstantEquation(value: $0) },
            volume: volume.map { ConstantEquation(value: $0) },
            molarity: molarity.map { ConstantEquation(value: $0) },
            concentration: concentration
        )
    }
}

// MARK: - Concentration
extension TitrationStrongSubstancePreEPModel {
    var concentration: EnumMap<TitrationEquationTerm.Concentration, Equation> {
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
    }

    // Note that we want the primary ion of the substance, to vary linearly to produce
    // the correct titration curve (the pH vs. substance added chart).
    private var hydrogenConcentration: Equation {
        if substance.type.isAcid {
            return LinearEquation(
                x1: 0,
                y1: previous.concentration.value(for: .hydrogen),
                x2: CGFloat(maxTitrant),
                y2: 1e-7
            )
        }

        return hydroxideConcentration.map(PrimaryIonConcentration.complementConcentration)
    }

    private var hydroxideConcentration: Equation {
        if substance.type.isAcid {
            return hydrogenConcentration.map(PrimaryIonConcentration.complementConcentration)
        }
        return LinearEquation(
            x1: 0,
            y1: previous.concentration.value(for: .hydroxide),
            x2: CGFloat(maxTitrant),
            y2: 1e-7
        )
    }
}

extension TitrationStrongSubstancePreEPModel {

    var kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat> {
        previous.kValues
    }

    var moles: EnumMap<TitrationEquationTerm.Moles, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .initialSecondary: return 0
            case .initialSubstance: return initialSubstanceMoles
            case .secondary: return 0
            case .substance: return initialSubstanceMoles
            case .titrant:
                return currentTitrantVolume * molarity.value(for: .titrant)
            }
        }
    }

    var volume: EnumMap<TitrationEquationTerm.Volume, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .substance: return previous.currentVolume
            case .titrant: return currentTitrantVolume
            case .initialSubstance: return previous.currentVolume
            case .initialSecondary: return 0
            case .equivalencePoint: return 0
            }
        }
    }

    var molarity: EnumMap<TitrationEquationTerm.Molarity, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return 0
            case .substance: return  previous.currentSubstanceConcentration
            case .titrant: return 0.5
            }
        }
    }

    var pValues: EnumMap<TitrationEquationTerm.PValue, Equation> {
        equationData.pValues
//        .init {
//            switch $0 {
//            case .hydrogen: return -1 * Log10Equation(underlying: concentration.value(for: .hydrogen))
//            case .hydroxide: return -1 * Log10Equation(underlying: concentration.value(for: .hydroxide))
//            case .kA: return ConstantEquation(value: previous.substance.pKA)
//            case .kB: return ConstantEquation(value: previous.substance.pKB)
//            }
//        }
    }

    var pH: Equation {
        pValues.value(for: .hydrogen)
    }

    private var initialSubstanceMolarity: CGFloat {
        previous.molarity.value(for: .substance)
    }

    private var initialSubstanceMoles: CGFloat {
        previous.moles.value(for: .substance)
    }

    private var finalTitrantVolume: CGFloat {
        initialSubstanceMoles / molarity.value(for: .titrant)
    }


}
