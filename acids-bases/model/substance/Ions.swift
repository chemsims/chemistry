//
// Reactions App
//

import Foundation

enum PrimaryIon {
    case hydrogen
    case hydroxide

    var complement: PrimaryIon {
        switch self {
        case .hydrogen: return .hydroxide
        case .hydroxide: return .hydrogen
        }
    }
}

enum SecondaryIon {
    case A
    case Cl
}
