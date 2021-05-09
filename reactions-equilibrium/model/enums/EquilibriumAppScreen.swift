//
// Reactions App
//

import Foundation

enum EquilibriumAppScreen: String, CaseIterable {
    case aqueousReaction,
         aqueousQuiz,
         integrationActivity,
         gaseousReaction,
         gaseousQuiz,
         solubility,
         solubilityQuiz,
         finalScreen

    var isQuiz: Bool {
        switch self {
        case .aqueousQuiz, .gaseousQuiz, .solubilityQuiz: return true
        default: return false
        }
    }
}
