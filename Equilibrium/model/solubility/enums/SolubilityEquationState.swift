//
// Reactions App
//

import Foundation

enum SolubilityEquationState {
    case showOriginalQuotient,
         showOriginalQuotientAndQuotientRecap,
         crossOutOriginalQuotientDenominator,
         showCorrectQuotientNotFilledIn,
         showCorrectQuotientFilledIn

    var doShowOriginalQuotient: Bool {
        switch self {
        case .showOriginalQuotient,
             .showOriginalQuotientAndQuotientRecap,
             .crossOutOriginalQuotientDenominator:
            return true
        default: return false
        }
    }

    var doShowCorrectQuotient: Bool {
        switch self {
        case .showCorrectQuotientFilledIn,
             .showCorrectQuotientNotFilledIn:
            return true
        default: return false
        }
    }

    var doCrossOutDenom: Bool {
        switch self {
        case .showOriginalQuotient, .showOriginalQuotientAndQuotientRecap: return false
        default: return true
        }
    }
}
