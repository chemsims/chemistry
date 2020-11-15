//
// Reactions App
//
  

import Foundation

enum BoundType {
    case upper, lower

    var reverse: BoundType {
        switch self {
        case .upper: return .lower
        case .lower: return .upper
        }
    }
}
