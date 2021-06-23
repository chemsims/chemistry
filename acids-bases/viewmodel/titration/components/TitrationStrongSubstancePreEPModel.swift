//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationStrongSubstancePreEPModel: ObservableObject {

    init(previous: TitrationStrongSubstancePreparationModel) {
        self.previous = previous
        let maxSubstance = 20
        self.maxTitrant = maxSubstance
        self.primaryIonCoords = AnimatingBeakerMolecules(
            molecules: previous.primaryIonCoords,
            fractionToDraw: LinearEquation(
                x1: 0,
                y1: 1,
                x2: CGFloat(maxSubstance),
                y2: 0
            ).within(min: 0, max: 1)
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
}

// MARK: Incrementing
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

// MARK: Titrant volume
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

// MARK: Bar chart data
extension TitrationStrongSubstancePreEPModel {
    var barChartData: [BarChartData] {
        [barChartData(forIon: .hydroxide), barChartData(forIon: .hydrogen)]
    }

    private func barChartData(forIon primaryIon: PrimaryIon) -> BarChartData {
        let isZero = previous.substance.primary != primaryIon
        return BarChartData(
            label: primaryIon.rawValue, // TODO get the charged symbol
            equation: isZero ? ConstantEquation(value: 0) : LinearEquation(
                x1: 0,
                y1: previous.currentSubstanceConcentration,
                x2: CGFloat(maxTitrant),
                y2: 0
            ),
            color: primaryIon.color,
            accessibilityLabel: "" // TODO
        )
    }
}

// MARK: Equation data
extension TitrationStrongSubstancePreEPModel {

    var equationData: TitrationEquationData {
        TitrationEquationData(
            substance: previous.substance,
            titrant: previous.titrant,
            moles: moles,
            volume: volume,
            molarity: molarity,
            concentration: concentration,
            pValues: pValues,
            kValues: kValues
        )
    }

    var kValues: EnumMap<TitrationEquationTerm.KValue, CGFloat> {
        previous.kValues
    }

    var concentration: EnumMap<TitrationEquationTerm.Concentration, CGFloat> {
        .init {
            switch $0 {
            case .hydrogen: return hydrogenConcentration
            case .hydroxide: return hydroxideConcentration.getY(at: CGFloat(titrantAdded))
            case .initialSecondary: return 0
            case .initialSubstance: return 0
            case .secondary: return 0
            case .substance: return 0
            }
        }
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

    var pH: Equation {
        -1 * Log10Equation(underlying: hydrogenConcentrationEquation)
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

    private var hydrogenConcentration: CGFloat {
        hydrogenConcentrationEquation
            .getY(at: CGFloat(titrantAdded))
    }

    private var hydrogenConcentrationEquation: Equation {
        LinearEquation(
            x1: 0,
            y1: previous.concentration.value(for: .hydrogen),
            x2: CGFloat(maxTitrant),
            y2: 1e-7
        )
    }

    private var hydroxideConcentration: Equation {
        hydrogenConcentrationEquation.map(PrimaryIonConcentration.complementConcentration)
    }
}
