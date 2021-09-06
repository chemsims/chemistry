//
// Reactions App
//

import SwiftUI

class BalancedReactionViewModel: ObservableObject {
    @Published var molecules = [MovingMolecule]()

    init() {
        let firstReactant = MovingMolecule(moleculeType: .ammonia, substanceType: .reactant, side: .first)
        let secondReactant = MovingMolecule(moleculeType: .carbonDioxide, substanceType: .reactant, side: .second)
        let firstProduct = MovingMolecule(moleculeType: .dioxygen, substanceType: .product, side: .first)
        let secondProduct = MovingMolecule(moleculeType: .methane, substanceType: .product, side: .second)

        molecules.append(firstReactant)
        molecules.append(secondReactant)
        molecules.append(firstProduct)
        molecules.append(secondProduct)
    }

    func add(molecule: MovingMolecule) {
        let countInBeaker = molecules.filter { m in
            m.moleculeType == molecule.moleculeType && m.isInBeaker
        }.count

        let newMoleculeInGrid = MovingMolecule(
            moleculeType: molecule.moleculeType,
            substanceType: molecule.substanceType,
            side: molecule.side
        )

        withAnimation(.addMolecule) {
            molecules.append(newMoleculeInGrid)
            for i in molecules.indices {
                if molecules[i].id == molecule.id {
                    molecules[i].position = .beaker(index: countInBeaker)
                }
            }
        }
    }

    func remove(molecule: MovingMolecule) {
        guard let moleculeBeakerIndex = molecule.beakerIndex else {
            return
        }

        withAnimation(.removeMolecule) {
            molecules.removeAll { $0.id == molecule.id }

            for moleculeIndex in molecules.indices {
                if molecules[moleculeIndex].moleculeType == molecule.moleculeType {
                    molecules[moleculeIndex].decrementBeakerIndexIfGreaterThan(moleculeBeakerIndex)
                }
            }
        }
    }
}

private extension Animation {
    static let addMolecule = Animation.easeOut(duration: 0.5)
    static let removeMolecule = Animation.easeOut(duration: 0.35)
}

extension BalancedReactionViewModel {

    struct MovingMolecule: Identifiable {
        let id = UUID()
        let moleculeType: BalancedReaction.Molecule
        let substanceType: BalancedReaction.SubstanceType
        let side: BalancedReaction.SidePart
        var position: MoleculePosition = .grid

        var isInBeaker: Bool {
            beakerIndex != nil
        }

        fileprivate mutating func decrementBeakerIndexIfGreaterThan(_ other: Int) {
            if let beakerIndex = beakerIndex, beakerIndex > other {
                self.position = .beaker(index: beakerIndex - 1)
            }
        }

        fileprivate var beakerIndex: Int? {
            if case let .beaker(index) = position {
                return index
            }
            return nil
        }
    }

    enum MoleculePosition {
        case grid
        case beaker(index: Int)
    }
}
