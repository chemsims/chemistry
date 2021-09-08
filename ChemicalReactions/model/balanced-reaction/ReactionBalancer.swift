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

    /// Returns true if the number of molecules added is an exact multiple of the reaction coefficients,
    /// where each multiple is the same, and greater than 1
    var isMultipleOfBalanced: Bool {
        if let reactantMultiple = reactantBalancer.multipleOfBalanced,
           let productMultiple = productBalancer.multipleOfBalanced {
            return reactantMultiple > 1 && reactantMultiple == productMultiple
        }
        return false
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

    func atomCount(of atom: BalancedReaction.Atom, elementType: BalancedReaction.ElementType) -> Int {
        switch elementType {
        case .reactant: return reactantBalancer.atomCount(of: atom)
        case .product: return productBalancer.atomCount(of: atom)
        }
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

    var multipleOfBalanced: Int? {
        let multiples = elements.compactMap { element -> Int? in
            let count = counts.value(for: element.molecule)
            if count % element.coefficient == 0 {
                return count / element.coefficient
            }
            return nil
        }

        let setOfMultiples = Set(multiples)
        if multiples.count == elements.count, setOfMultiples.count == 1 {
            return setOfMultiples.first!
        }
        return nil
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

    /// Returns the count of atoms added to this side of the reaction
    func atomCount(of atom: BalancedReaction.Atom) -> Int {
        BalancedReaction.Molecule.allCases.map { molecule -> Int in
            guard let moleculeCount = count(of: molecule),
                  let atomCount = molecule.count(of: atom) else {
                return 0
            }
            return atomCount * moleculeCount
        }.sum()
    }
}
