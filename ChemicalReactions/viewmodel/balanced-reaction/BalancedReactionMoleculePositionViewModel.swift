//
// Reactions App
//

import SwiftUI

class BalancedReactionMoleculePositionViewModel: ObservableObject {

    let reaction: BalancedReaction
    @Published var molecules = [MovingMolecule]()
    @Published var reactionBalancer: ReactionBalancer

    /// Create a new model to keep track of molecule positions
    ///
    /// - Parameter isBalanced: Whether the reaction should start off in the balanced state
    init(reaction: BalancedReaction, isBalanced: Bool = false) {
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

        if isBalanced {
            balanceReaction()
        }
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

    /// Adds all required molecules needed to balance the reaction.
    /// Note, this will not remove molecules if there are too many.
    private func balanceReaction() {
        balanceElements(elements: reaction.products, type: .product)
        balanceElements(elements: reaction.reactants, type: .reactant)
    }

    private func balanceElements(
        elements: BalancedReaction.Elements,
        type: BalancedReaction.ElementType
    ) {
        balanceSingleElement(elements.first, type: type, side: .first)
        if let secondElement = elements.second {
            balanceSingleElement(secondElement, type: type, side: .second)
        }
    }


    private func balanceSingleElement(
        _ element: BalancedReaction.Element,
        type: BalancedReaction.ElementType,
        side: BalancedReaction.ElementOrder
    ) {
        let count = reactionBalancer.count(of: element.molecule)
        let desiredCount = element.coefficient
        let deficit = desiredCount - count
        if deficit > 0 {
            (0..<deficit).forEach { index in
                let molecule = MovingMolecule(
                    moleculeType: element.molecule,
                    elementType: type,
                    side: side,
                    position: .beaker(index: count + index)
                )
                molecules.append(molecule)
                reactionBalancer.add(element.molecule, to: type)
            }
        }
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
