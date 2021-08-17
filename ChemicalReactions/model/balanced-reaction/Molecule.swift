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

    enum MoleculeStructure {
        case double(atom: BalancedReaction.Atom),
             oneToTwoHorizontal(singleAtom: BalancedReaction.Atom, doubleAtom: BalancedReaction.Atom),
             oneToTwoPyramid(singleAtom: BalancedReaction.Atom, doubleAtom: BalancedReaction.Atom),
             oneToThree(singleAtom: BalancedReaction.Atom, tripleAtom: BalancedReaction.Atom),
             oneToFour(singleAtom: BalancedReaction.Atom, quadAtom: BalancedReaction.Atom)
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

extension BalancedReaction.MoleculeStructure {

    static let ammonia = BalancedReaction.MoleculeStructure.oneToThree(
        singleAtom: .nitrogen,
        tripleAtom: .hydrogen
    )

    static let carbonDioxide = BalancedReaction.MoleculeStructure.oneToTwoHorizontal(
        singleAtom: .carbon,
        doubleAtom: .oxygen
    )

    static let dinitrogen = BalancedReaction.MoleculeStructure.double(atom: .nitrogen)

    static let dihydrogen = BalancedReaction.MoleculeStructure.double(atom: .hydrogen)

    static let dioxygen = BalancedReaction.MoleculeStructure.double(atom: .oxygen)

    static let methane = BalancedReaction.MoleculeStructure.oneToFour(
        singleAtom: .carbon,
        quadAtom: .hydrogen
    )

    static let nitriteIon = BalancedReaction.MoleculeStructure.oneToTwoHorizontal(
        singleAtom:  .nitrogen,
        doubleAtom: .oxygen
    )

    static let water = BalancedReaction.MoleculeStructure.oneToTwoPyramid(
        singleAtom: .oxygen,
        doubleAtom: .hydrogen
    )
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

    func atom(withCount count: Int) -> BalancedReaction.Atom? {
        atoms.first { $0.count == count }?.atom
    }
}
