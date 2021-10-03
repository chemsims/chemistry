//
// Reactions App
//

import Foundation

public enum ElementState {
    case aqueous, liquid, solid, gaseous

    public var symbol: String {
        switch self {
        case .aqueous: return "aq"
        case .liquid: return "l"
        case .solid: return "s"
        case .gaseous: return "g"
        }
    }
}
