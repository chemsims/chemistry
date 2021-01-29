//
// Reactions App
//
  

import Foundation

enum AppScreen: String, CaseIterable {
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

extension AppScreen {
    var isQuiz: Bool {
        switch (self) {
        case .zeroOrderReactionQuiz, .firstOrderReactionQuiz, .secondOrderReactionQuiz,
             .reactionComparisonQuiz, .energyProfileQuiz:
            return true
        default: return false
        }
    }
}
