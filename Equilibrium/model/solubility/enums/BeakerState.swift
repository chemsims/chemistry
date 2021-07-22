//
// Reactions App
//

import Foundation

enum BeakerState: Equatable {
    case none
    case addingSolute(type: SoluteType)
    case addingSaturatedPrimary
    case demoReaction

    var shouldDissolve: Bool {
        isAddingNonSaturatedSolute || self == .demoReaction
    }

    var isAddingNonSaturatedSolute: Bool  {
        if case .addingSolute = self {
            return true
        }
        return false
    }

    var soluteType: SoluteType {
        switch self {
        case let .addingSolute(type: type):
            return type
        default: return .primary
        }
    }
}
