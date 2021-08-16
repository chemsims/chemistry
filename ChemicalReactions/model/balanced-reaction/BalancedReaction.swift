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
}

