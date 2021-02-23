//
// Reactions App
//


import Foundation

enum AqueousMolecule: String, CaseIterable {
    case A, B, C, D
}

extension AqueousMolecule {
    var imageName: String {
        "molecule\(self.rawValue)"
    }
}
