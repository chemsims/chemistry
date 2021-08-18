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
        self.reactantBalancer = ReactionSideBalancer(molecules: reaction.reactants)
        self.productBalancer = ReactionSideBalancer(molecules: reaction.products)
    }

    let reaction: BalancedReaction

    private var reactantBalancer: ReactionSideBalancer
    private var productBalancer: ReactionSideBalancer

    /// Reaction is balanced number of molecules added to the reactants & products equals the coefficients of the original reaction
    var isBalanced: Bool {
        reactantBalancer.isBalanced && productBalancer.isBalanced
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

private struct ReactionSideBalancer {
    let molecules: [BalancedReaction.MoleculeCount]
    private(set) var counts = EnumMap<BalancedReaction.Molecule, Int>.constant(0)

    var isBalanced: Bool {
        molecules.allSatisfy { molecule in
            counts.value(for: molecule.molecule) == molecule.coefficient
        }
    }

    mutating func add(_ molecule: BalancedReaction.Molecule) {
        assert(molecules.map(\.molecule).contains(molecule))
        let currentCount = counts.value(for: molecule)
        counts = counts.updating(with: currentCount + 1, for: molecule)
    }

    mutating func remove(_ molecule: BalancedReaction.Molecule) {
        assert(molecules.map(\.molecule).contains(molecule))
        let currentCount = counts.value(for: molecule)
        if currentCount > 0 {
            counts = counts.updating(with: currentCount - 1, for: molecule)
        }
    }
}
