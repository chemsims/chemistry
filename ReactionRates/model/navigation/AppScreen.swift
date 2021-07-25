//
// Reactions App
//

import Foundation
import ReactionsCore

public enum AppScreen: String, CaseIterable {
    case zeroOrderReaction,
         zeroOrderReactionQuiz,
         zeroOrderFiling,
         firstOrderReaction,
         firstOrderReactionQuiz,
         firstOrderFiling,
         secondOrderReaction,
         secondOrderReactionQuiz,
         secondOrderFiling,
         reactionComparison,
         reactionComparisonQuiz,
         energyProfile,
         energyProfileQuiz,
         energyProfileFiling,
         finalAppScreen
}

extension AppScreen : HasAnalyticsLabel {
    // We decided to bundle units into 1 app after reaction rates was released, so there is already
    // analytics data. So we avoid adding any prefix here to the screens, so that there's no loss
    // in data history
    public var analyticsLabel: String {
        self.rawValue
    }
}

extension AppScreen {
    var isQuiz: Bool {
        switch self {
        case .zeroOrderReactionQuiz, .firstOrderReactionQuiz, .secondOrderReactionQuiz,
             .reactionComparisonQuiz, .energyProfileQuiz:
            return true
        default: return false
        }
    }
}
