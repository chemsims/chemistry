//
// Reactions App
//

import Foundation
import ReactionsCore

enum TitrationEquation: Equatable {
    typealias Term = TitrationEquationTerm
    typealias Placeholder = Term.Placeholder


    case molesToMolarity(
            moles: Placeholder<Term.Moles>,
            volume: Placeholder<Term.Volume>,
            molarity: Placeholder<Term.Molarity>
         )

    case concentrationToMolesOverVolume(
            concentration: Placeholder<Term.Concentration>,
            moles: Placeholder<Term.Moles>,
            firstVolume: Placeholder<Term.Volume>,
            secondVolume: Placeholder<Term.Volume>
         )

    case pConcentration(
            pValue: Placeholder<Term.PValue>,
            concentration: Placeholder<Term.Concentration>
         )

    case pSum(firstPValue: Placeholder<Term.PValue>, secondPValue: Placeholder<Term.PValue>)

    case kToConcentration(
            kValue: Placeholder<Term.KValue>,
            firstNumeratorConcentration: Placeholder<Term.Concentration>,
            secondNumeratorConcentration: Placeholder<Term.Concentration>,
            denominatorConcentration: Placeholder<Term.Concentration>
         )

    case kW(kA: Placeholder<Term.KValue>, kB: Placeholder<Term.KValue>)

    case molesDifference(
            difference: Placeholder<Term.Moles>,
            subtracting: Placeholder<Term.Moles>,
            from: Placeholder<Term.Moles>
         )

    case pKLog(
            pConcentration: Placeholder<Term.PValue>,
            pK: Placeholder<Term.PValue>,
            numeratorConcentration: Placeholder<Term.Concentration>,
            denominatorConcentration: Placeholder<Term.Concentration>
         )

    case pToLogK(
            pValue: Placeholder<Term.PValue>,
            kValue: Placeholder<Term.KValue>
         )

    case molesToConcentration(
            moles: Placeholder<Term.Moles>,
            concentration: Placeholder<Term.Concentration>,
            volume: Placeholder<Term.Volume>
         )

    case concentrationToMolesDifferenceOverVolume(
            concentration: Term.Placeholder<Term.Concentration>,
            subtractingMoles: Term.Placeholder<Term.Moles>,
            fromMoles: Term.Placeholder<Term.Moles>,
            firstVolume: Term.Placeholder<Term.Volume>,
            secondVolume: Term.Placeholder<Term.Volume>
         )

    case pLogComplementConcentration(
            pValue: Placeholder<Term.PValue>,
            concentration: Placeholder<Term.Concentration>
         )

    indirect case filled(_ underlying: TitrationEquation)
}

extension TitrationEquationTerm: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(self)"
    }
}
