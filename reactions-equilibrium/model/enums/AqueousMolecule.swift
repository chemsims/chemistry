//
// Reactions App
//


import Foundation

enum AqueousMolecule: String, CaseIterable {
    case A, B, C, D
}


enum AqueousMoleculeReactant: String {
    case A, B
}

enum AqueousMoleculeProduct {
    case C, D
}

extension AqueousMolecule {
    var imageName: String {
        "molecule\(self.rawValue)"
    }
}
