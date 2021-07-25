//
// Reactions App
//

import Foundation
import ReactionsCore

public enum EquilibriumAppScreen: String, CaseIterable {
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

extension EquilibriumAppScreen : HasAnalyticsLabel {
    public var analyticsLabel: String {
        "equilibrium_\(self.rawValue)"
    }
}
