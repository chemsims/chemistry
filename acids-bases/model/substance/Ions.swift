//
// Reactions App
//

import SwiftUI
import ReactionsCore

enum PrimaryIon: String {
    case hydrogen = "H"
    case hydroxide = "OH"

    var complement: PrimaryIon {
        switch self {
        case .hydrogen: return .hydroxide
        case .hydroxide: return .hydrogen
        }
    }

    var rgb: RGB {
        switch self {
        case .hydrogen: return .hydrogen
        case .hydroxide: return .hydroxide
        }
    }

    var color: Color {
        rgb.color
    }
}

enum SecondaryIon: String {
    case A
    case Cl

    // TODO use color names which correspond with symbol names
    var rgb: RGB {
        switch self {
        case .A: return RGB.moleculeA
        case .Cl: return RGB.moleculeB
        }
    }

    var color: Color {
        rgb.color
    }
}
