//
// Reactions App
//

import ReactionsCore

public enum ChemicalReactionsScreen: String, CaseIterable {
    case balancedReactions,
         balancedReactionsQuiz,
         limitingReagent,
         limitingReagentQuiz
}

extension ChemicalReactionsScreen: HasAnalyticsLabel {
    public var analyticsLabel: String {
        "chemicalReactions_\(rawValue)"
    }
}
