//
// Reactions App
//

import XCTest
@testable import ChemicalReactions

class AvailableBalancedReactionsValidityTests: XCTestCase {

    func testThatAvailableReactionsHaveBalancedAtoms() {
        BalancedReaction.availableReactions.indices.forEach { index in
            let reaction = BalancedReaction.availableReactions[index]
            XCTAssertEqual(reaction.reactantAtomCounts, reaction.productAtomCounts, "Index \(index)")
        }
    }
}


private extension BalancedReaction {

    var reactantAtomCounts: [Atom:Int] {
        combinedAtomCounts(of: reactants)
    }

    var productAtomCounts: [Atom:Int] {
        combinedAtomCounts(of: products)
    }

    private func combinedAtomCounts(of elements: Elements) -> [Atom:Int] {

        var result = [Atom:Int]()

        elements.asArray.forEach { element in
            element.molecule.atoms.forEach { atomCount in
                let fullAtomCount = element.coefficient * atomCount.count
                if let currentCount = result[atomCount.atom] {
                    result[atomCount.atom] = currentCount + fullAtomCount
                } else {
                    result[atomCount.atom] = fullAtomCount
                }
            }
        }

        return result
    }
}
