//
// Reactions App
//

import Foundation

public enum Unit {
    case reactionRates,
         equilibrium,
         acidsAndBases
}

extension Unit {
    public var bundle: Bundle? {
        Bundle(identifier: bundleId)
    }

    private var bundleId: String {
        switch self {
        case .reactionRates: return "com.reactions.unit.ReactionRates"
        default: return "com.reactions.unit.Equilibrium"
        }
    }
}
