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

    struct Element {
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
    var atoms: Set<BalancedReaction.Atom> {
        switch self {
        case let .double(atom): return [atom]
        case let .oneToFour(single, quad): return [single, quad]
        case let .oneToThree(single, triple): return [single, triple]
        case let .oneToTwoHorizontal(single, double): return [single, double]
        case let .oneToTwoPyramid(single, double): return [single, double]
        }
    }
}

extension BalancedReaction.Molecule {
    var structure: BalancedReaction.MoleculeStructure {
        switch self {
        case .ammonia:
            return .oneToThree(singleAtom: .nitrogen, tripleAtom: .hydrogen)
        case .carbonDioxide:
            return .oneToTwoHorizontal(singleAtom: .carbon, doubleAtom: .oxygen)
        case .dihydrogen:
            return .double(atom: .hydrogen)
        case .dinitrogen:
            return .double(atom: .nitrogen)
        case .dioxygen:
            return .double(atom: .oxygen)
        case .methane:
            return .oneToFour(singleAtom: .carbon, quadAtom: .hydrogen)
        case .nitriteIon:
            return .oneToTwoHorizontal(singleAtom: .nitrogen, doubleAtom: .oxygen)
        case .water:
            return .oneToTwoPyramid(singleAtom: .oxygen, doubleAtom: .hydrogen)
        }
    }
}
