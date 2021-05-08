//
// Reactions App
//

import Foundation

enum EquilibriumAppScreen: String, CaseIterable {
    case aqueousReaction,
         aqueousQuiz,
         gaseousReaction,
         gaseousQuiz,
         solubility,
         solubilityQuiz,
         integrationActivity,
         finalScreen

    var isQuiz: Bool {
        switch self {
        case .aqueousQuiz, .gaseousQuiz, .solubilityQuiz: return true
        default: return false
        }
    }
}
