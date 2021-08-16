//
// Reactions App
//

import Foundation

extension BalancedReaction {
    enum Molecule: CaseIterable {
        case dinitrogen,
             dihydrogen,
             ammonia,
             water,
             dioxygen,
             methane,
             carbonDioxide,
             nitriteIon
    }

    struct MoleculeCount {
        init(molecule: BalancedReaction.Molecule, coefficient: Int) {
            assert(coefficient >= 1)
            self.molecule = molecule
            self.coefficient = coefficient
        }

        let molecule: BalancedReaction.Molecule
        let coefficient: Int
    }
}

extension BalancedReaction.Molecule {
    var atoms: [BalancedReaction.AtomCount] {
        switch self {
        case .ammonia: return [
            .init(atom: .nitrogen, count: 1),
            .init(atom: .hydrogen, count: 3)
        ]
        case .carbonDioxide: return [
            .init(atom: .carbon, count: 1),
            .init(atom: .oxygen, count: 2)
        ]
        case .dihydrogen: return [
            .init(atom: .hydrogen, count: 2)
        ]
        case .dinitrogen: return [
            .init(atom: .nitrogen, count: 2)
        ]
        case .dioxygen: return [
            .init(atom: .oxygen, count: 2)
        ]
        case .methane: return [
            .init(atom: .carbon, count: 1),
            .init(atom: .hydrogen, count: 4)
        ]
        case .nitriteIon: return [
            .init(atom: .nitrogen, count: 1),
            .init(atom: .oxygen, count: 2)
        ]
        case .water: return [
            .init(atom: .hydrogen, count: 1),
            .init(atom: .oxygen, count: 2)
        ]
        }
    }
}
