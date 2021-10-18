//
// Reactions App
//

import ReactionsCore

public enum ChemicalReactionsScreen: String, CaseIterable {
    case balancedReactions,
         balancedReactionsQuiz,
         limitingReagent,
         limitingReagentQuiz,
         precipitation,
         precipitationQuiz
}

extension ChemicalReactionsScreen: HasAnalyticsLabel {
    public var analyticsLabel: String {
        "chemicalReactions_\(rawValue)"
    }
}
