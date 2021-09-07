//
// Reactions App
//

import Foundation
import ReactionsCore

/// Tracks molecules which have been added to each side of a reaction, and compares this
/// to the coefficients of the provided reaction.
struct ReactionBalancer {

    init(reaction: BalancedReaction) {
        self.reaction = reaction
        self.reactantBalancer = ReactionSideBalancer(elements: reaction.reactants.asArray)
        self.productBalancer = ReactionSideBalancer(elements: reaction.products.asArray)
    }

    let reaction: BalancedReaction

    private var reactantBalancer: ReactionSideBalancer
    private var productBalancer: ReactionSideBalancer

    /// Reaction is balanced number of molecules added to the reactants & products equals the coefficients of the original reaction
    var isBalanced: Bool {
        reactantBalancer.isBalanced && productBalancer.isBalanced
    }

    mutating func add(_ molecule: BalancedReaction.Molecule, to type: BalancedReaction.ElementType) {
        switch type {
        case .reactant: addReactant(molecule)
        case .product: addProduct(molecule)
        }
    }

    mutating func remove(_ molecule: BalancedReaction.Molecule, from type: BalancedReaction.ElementType) {
        switch type {
        case .reactant: removeReactant(molecule)
        case .product: removeProduct(molecule)
        }
    }

    /// Adds one `molecule` to the reactants.
    mutating func addReactant(_ molecule: BalancedReaction.Molecule) {
        reactantBalancer.add(molecule)
    }

    /// Adds one `molecule` to the products.
    mutating func addProduct(_ molecule: BalancedReaction.Molecule) {
        productBalancer.add(molecule)
    }

    /// Removes one `molecule` from the reactants, if there is at least one  of `molecule` present.
    mutating func removeReactant(_ molecule: BalancedReaction.Molecule) {
        reactantBalancer.remove(molecule)
    }

    /// Removes one `molecule` from the products, if there is at least one  of `molecule` present.
    mutating func removeProduct(_ molecule: BalancedReaction.Molecule) {
        productBalancer.remove(molecule)
    }
}

extension ReactionBalancer {

    /// Returns the count of `molecule` added to the beaker
    func count(of molecule: BalancedReaction.Molecule) -> Int {
        reactantBalancer.count(of: molecule) ?? productBalancer.count(of: molecule) ?? 0
    }
}

private struct ReactionSideBalancer {

    init(elements: [BalancedReaction.Element]) {
        self.elements = elements
        self.molecules = Set(elements.map(\.molecule))
    }

    let elements: [BalancedReaction.Element]
    private(set) var counts = EnumMap<BalancedReaction.Molecule, Int>.constant(0)

    let molecules: Set<BalancedReaction.Molecule>

    var isBalanced: Bool {
        elements.allSatisfy { molecule in
            counts.value(for: molecule.molecule) == molecule.coefficient
        }
    }

    mutating func add(_ molecule: BalancedReaction.Molecule) {
        guard molecules.contains(molecule) else {
            return
        }
        let currentCount = counts.value(for: molecule)
        counts = counts.updating(with: currentCount + 1, for: molecule)
    }

    mutating func remove(_ molecule: BalancedReaction.Molecule) {
        guard molecules.contains(molecule) else {
            return
        }
        let currentCount = counts.value(for: molecule)
        if currentCount > 0 {
            counts = counts.updating(with: currentCount - 1, for: molecule)
        }
    }

    /// Returns the count of `molecule`, if this balancer is keeping track of the the molecule
    func count(of molecule: BalancedReaction.Molecule) -> Int? {
        guard molecules.contains(molecule) else {
            return nil
        }
        return counts.value(for: molecule)
    }
}
