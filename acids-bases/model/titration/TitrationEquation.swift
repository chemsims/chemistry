//
// Reactions App
//

import Foundation
import ReactionsCore

enum TitrationEquation {
    typealias Term = TitrationEquationTerm

    case molesToVolume(moles: Term.Moles, volume: Term.Volume, molarity: Term.Molarity)

    case concentrationToMolesAndVolume(
            concentration: Term.Placeholder<Term.Concentration>,
            moles: Term.Placeholder<Term.Moles>,
            firstVolume: Term.Placeholder<Term.Volume>,
            secondVolume: Term.Volume
         )

    case pConcentration(pValue: Term.PValue, concentration: Term.Concentration)

    case pSum(firstPValue: Term.PValue, secondPValue: Term.PValue)

    case kToConcentration(
            kValue: Term.KValue,
            firstNumeratorConcentration: Term.PValue,
            secondNumeratorConcentration: Term.PValue,
            denominatorConcentration: Term.Concentration
         )

    case kW(kA: Term.KValue, kB: Term.KValue)

    // TIL: difference = minuend - subtrahend
    case molesSum(difference: Term.Moles, subtracting: Term.Moles, from: Term.Moles)

    case pKLog(
            pConcentration: Term.PValue,
            pK: Term.PValue,
            numeratorConcentration: Term.Concentration,
            denominatorConcentration: Term.Concentration
         )

    case molesToConcentration(
            moles: Term.Moles,
            concentration: Term.Concentration,
            volume: Term.Volume
         )

    case concentrationToMolesOverVolume(
            concentration: Term.Concentration,
            subtractingMoles: Term.Concentration,
            fromMoles: Term.Concentration,
            firstVolume: Term.Volume,
            secondVolume: Term.Volume
         )

    case pHToHydroxide(pH: Term.PValue, hydroxideConcentration: Term.Concentration)
}

extension TitrationEquation: Identifiable {
    var id: Int {
        switch self {
        case .concentrationToMolesAndVolume: return 0
        case .concentrationToMolesOverVolume: return 1
        case .kToConcentration: return 2
        case .kW: return 3
        case .molesSum: return 4
        case .molesToConcentration: return 5
        case .molesToVolume: return 6
        case .pConcentration: return 7
        case .pHToHydroxide: return 8
        case .pKLog: return 9
        case .pSum: return 10
        }
    }
}
