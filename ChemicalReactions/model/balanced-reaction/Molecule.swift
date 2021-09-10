//
// Reactions App
//

import Foundation
import ReactionsCore

extension BalancedReaction {
    enum Molecule: String, CaseIterable {
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

    struct Element: Equatable {
        init(molecule: BalancedReaction.Molecule, coefficient: Int) {
            assert(coefficient >= 1)
            self.molecule = molecule
            self.coefficient = coefficient
        }

        let molecule: BalancedReaction.Molecule
        let coefficient: Int
    }
}

extension BalancedReaction.Element {
    var id: String {
        molecule.atoms.map { atomCount in
            return "\(atomCount.count)\(atomCount.atom.name)"
        }.reduce("") { $0 + $1 }
    }
}

extension BalancedReaction.Molecule {

    func count(of atom: BalancedReaction.Atom) -> Int? {
        atoms.first { $0.atom == atom }?.count
    }

    var atoms: [BalancedReaction.AtomCount] {
        switch self.structure {
        case let .double(atom):
            return [.init(atom: atom, count: 2)]

        case let .oneToFour(single, quad):
            return [.init(atom: single, count: 1), .init(atom: quad, count: 4)]

        case let .oneToThree(single, triple):
            return [.init(atom: single, count: 1), .init(atom: triple, count: 3)]

        case let .oneToTwoHorizontal(single, double):
            return [.init(atom: single, count: 1), .init(atom: double, count: 2)]

        case let .oneToTwoPyramid(single, double):
            return [.init(atom: single, count: 1), .init(atom: double, count: 2)]
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

    var textLine: TextLine {
        switch self.structure {
        case let .double(atom):
            return "\(atom.symbol)_2_"

        case let .oneToFour(single, quad):
            return "\(single.symbol)\(quad.symbol)_4_"

        case let .oneToThree(single, triple):
            return "\(single.symbol)\(triple.symbol)_3_"

        case let .oneToTwoHorizontal(single, double):
            return "\(single.symbol)\(double.symbol)_2_"

        case let .oneToTwoPyramid(single, double):
            return "\(double.symbol)_2_\(single.symbol)"
        }
    }
}

extension BalancedReaction.Molecule {

    var name: String {
        let parts = self.rawValue.split { $0.isUppercase }
        if let firstPart = parts.first {
            let subSequence = parts.dropFirst().reduce(firstPart) {
                $0 + " \($1)"
            }
            return String(subSequence)
        }
        return ""
    }
}
