//
// Reactions App
//

import SwiftUI

class BalancedReactionMoleculePositionViewModel: ObservableObject {

    let reaction: BalancedReaction
    @Published var molecules = [MovingMolecule]()
    @Published var reactionBalancer: ReactionBalancer

    init(reaction: BalancedReaction) {
        self.reaction = reaction
        self.reactionBalancer = ReactionBalancer(reaction: reaction)

        func addInitialMolecules(_ type: BalancedReaction.ElementType) {
            let elements = reaction.elements(ofType: type)
            molecules.append(
                MovingMolecule(
                    moleculeType: elements.first.molecule,
                    elementType: type,
                    side: .first
                )
            )
            if let secondElement = elements.second {
                molecules.append(
                    MovingMolecule(
                        moleculeType: secondElement.molecule,
                        elementType: type,
                        side: .second
                    )
                )
            }
        }

        addInitialMolecules(.reactant)
        addInitialMolecules(.product)
    }

    /// Attempts to drop the molecule on the beaker, returning true if the molecule was added
    func drop(
        molecule: MovingMolecule,
        on elementType: BalancedReaction.ElementType
    ) -> Bool {

        // When adding a molecule using an accessibility action, there is a delay where the exact
        // same action can be repeated, with the same molecule that was initially provided. This
        // means the molecule being passed in says that it is not in the beaker, even though
        // we already added it. So we check that the molecule being passed in exists in the same
        // state as the array of molecules
        guard let matchingMolecule = molecules.first(where: { $0.id == molecule.id}),
              matchingMolecule == molecule else {
                  return false
              }

        let countInBeaker = reactionBalancer.count(of: molecule.moleculeType)
        guard countInBeaker < BalancedReactionBeakerMoleculeLayout.maxCount else {
            return false
        }

        guard !molecule.isInBeaker && molecule.elementType == elementType else {
            return false
        }
        add(molecule: molecule, withIndex: countInBeaker)
        return true
    }

    /// Attempts to add the molecule on the beaker, returning true if the molecule was added
    private func add(
        molecule: MovingMolecule,
        withIndex index: Int
    ) {
        let newMoleculeInGrid = MovingMolecule(
            moleculeType: molecule.moleculeType,
            elementType: molecule.elementType,
            side: molecule.side
        )

        reactionBalancer.add(molecule.moleculeType, to: molecule.elementType)

        for i in molecules.indices {
            if molecules[i].id == molecule.id {
                molecules[i].position = .beaker(index: index)
            }
        }

        withAnimation(.addMolecule) {
            molecules.append(newMoleculeInGrid)
        }

    }

    /// Attempts to remove `molecule` from the beaker, returning true iff it was removed
    func remove(molecule: MovingMolecule) -> Bool {
        guard let moleculeBeakerIndex = molecule.beakerIndex else {
            return false
        }

        reactionBalancer.remove(molecule.moleculeType, from: molecule.elementType)

        molecules.removeAll { $0.id == molecule.id }

        for moleculeIndex in molecules.indices {
            if molecules[moleculeIndex].moleculeType == molecule.moleculeType {
                molecules[moleculeIndex].decrementBeakerIndexIfGreaterThan(moleculeBeakerIndex)
            }
        }

        return true
    }
}
extension BalancedReactionMoleculePositionViewModel {

    struct MovingMolecule: Identifiable, Equatable {
        let id = UUID()
        let moleculeType: BalancedReaction.Molecule
        let elementType: BalancedReaction.ElementType
        let side: BalancedReaction.ElementOrder
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

    enum MoleculePosition: Equatable {
        case grid
        case beaker(index: Int)
    }
}
