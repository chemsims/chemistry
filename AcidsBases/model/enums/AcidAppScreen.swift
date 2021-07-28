//
// Reactions App
//

import Foundation
import ReactionsCore

public enum AcidAppScreen: String, CaseIterable {
    case introduction,
         introductionQuiz,
         buffer,
         bufferQuiz,
         titration,
         titrationQuiz,
         finalAppScreen

    var isQuiz: Bool {
        switch self {
        case .introductionQuiz, .bufferQuiz, .titrationQuiz: return true
        default: return false
        }
    }
}

extension AcidAppScreen: HasAnalyticsLabel {
    public var analyticsLabel: String {
        "acidsBases_\(rawValue)"
    }
}
