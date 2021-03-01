//
// Reactions App
//


import Foundation

enum AqueousMolecule: String, CaseIterable {
    case A, B, C, D
}


enum AqueousMoleculeReactant {
    case A, B
}

extension AqueousMolecule {
    var imageName: String {
        "molecule\(self.rawValue)"
    }
}
