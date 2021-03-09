//
// Reactions App
//

import SwiftUI

enum AqueousMolecule: String, CaseIterable {
    case A, B, C, D

    var isReactant: Bool {
        self == .A || self == .B
    }

    var isProduct: Bool {
        self == .C || self == .D
    }
}


enum AqueousMoleculeReactant: String {
    case A, B
}

enum AqueousMoleculeProduct {
    case C, D
}

extension AqueousMolecule {
    var color: Color {
        switch self {
        case .A: return .from(.aqMoleculeA)
        case .B: return .from(.aqMoleculeB)
        case .C: return .from(.aqMoleculeC)
        case .D: return .from(.aqMoleculeD)
        }
    }
}

extension AqueousMolecule {
    var imageName: String {
        "molecule\(self.rawValue)"
    }
}
