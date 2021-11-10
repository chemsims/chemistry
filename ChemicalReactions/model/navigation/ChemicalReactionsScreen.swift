//
// Reactions App
//

import ReactionsCore

public enum ChemicalReactionsScreen: String, CaseIterable {
    case balancedReactions,
         balancedReactionsQuiz,
         balancedReactionsFilingCabinet,
         limitingReagent,
         limitingReagentQuiz,
         limitingReagentFilingCabinet,
         precipitation,
         precipitationQuiz,
         finalAppScreen

    var isQuiz: Bool {
        switch self {
        case .balancedReactionsQuiz, .limitingReagentQuiz, .precipitationQuiz: return true
        default: return false
        }
    }
}

extension ChemicalReactionsScreen: HasAnalyticsLabel {
    public var analyticsLabel: String {
        "chemicalReactions_\(rawValue)"
    }
}
