//
// Reactions App
//

import Foundation

struct BalancedReaction {

    init(reactants: [MoleculeCount], products: [MoleculeCount]) {
        assert(!reactants.isEmpty)
        assert(!products.isEmpty)
        self.reactants = reactants
        self.products = products

        self.molecules = Set((reactants + products).map(\.molecule))
    }

    let reactants: [MoleculeCount]
    let products: [MoleculeCount]
    let molecules: Set<BalancedReaction.Molecule>

    /// Represents one side of a reaction - i.e., either reactants or products.
    enum Side {
        case single(molecule: MoleculeCount)
        case double(first: MoleculeCount, second: MoleculeCount)
    }
}

