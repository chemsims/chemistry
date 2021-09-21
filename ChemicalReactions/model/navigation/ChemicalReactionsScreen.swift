//
// Reactions App
//

import ReactionsCore

public enum ChemicalReactionsScreen: String, CaseIterable {
    case balancedReactions,
         limitingReagent
}

extension ChemicalReactionsScreen: HasAnalyticsLabel {
    public var analyticsLabel: String {
        "chemicalReactions_\(rawValue)"
    }
}
