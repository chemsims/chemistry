//
// Reactions App
//

import SwiftUI
import ReactionsCore

enum AqueousMolecule: String, CaseIterable {
    case A, B, C, D

    var isReactant: Bool {
        self == .A || self == .B
    }

    var isProduct: Bool {
        self == .C || self == .D
    }

    /// Returns the complementing molecule. For example, a reactant would return the other reactant
    var complement: AqueousMolecule {
        switch self {
        case .A: return .B
        case .B: return .A
        case .C: return .D
        case .D: return .C
        }
    }
}


enum AqueousMoleculeReactant: String {
    case A, B

    var molecule: AqueousMolecule {
        switch self {
        case .A: return .A
        case .B: return .B
        }
    }
}

enum AqueousMoleculeProduct {
    case C, D
}

extension AqueousMolecule {

    var rgb: RGB {
        switch self {
        case .A: return .aqMoleculeA
        case .B: return .aqMoleculeB
        case .C: return .aqMoleculeC
        case .D: return .aqMoleculeD
        }
    }

    var color: Color {
        rgb.color
    }
}

extension AqueousMolecule {
    var imageName: String {
        "molecule\(self.rawValue)"
    }
}
