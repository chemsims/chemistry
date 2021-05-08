//
// Reactions App
//

import Foundation

enum ReactionDefinitionArrowDirection {
    case forward, reverse, equilibrium, none

    static func from(direction: ReactionDirection) -> ReactionDefinitionArrowDirection {
        direction == .forward ? .forward : .reverse
    }

    var label: String? {
        switch self {
        case .equilibrium: return "top arrow is moving to the right and bottom arrow is moving to the left"
        case .forward: return "top arrow is moving to the right"
        case .reverse: return "bottom arrow is moving to the left"
        default: return nil
        }
    }
}
