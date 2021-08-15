//
// Reactions App
//

import Foundation
import ReactionsCore

public enum EquilibriumScreen: String, CaseIterable {
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

extension EquilibriumScreen : HasAnalyticsLabel {
    public var analyticsLabel: String {
        "equilibrium_\(self.rawValue)"
    }
}
