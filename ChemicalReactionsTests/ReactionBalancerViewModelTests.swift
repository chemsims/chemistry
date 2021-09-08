//
// Reactions App
//

import XCTest
@testable import ChemicalReactions

class ReactionBalancerViewModelTests: XCTestCase {

    func testReactionIsBalancedAfterAddingCorrectNumberOfMolecules() {
        let reaction = BalancedReaction(
            reactants: .one(element: .init(molecule: .water, coefficient: 1)),
            products: .two(
                first: .init(molecule: .dihydrogen, coefficient: 1),
                second: .init(molecule: .dioxygen, coefficient: 1)
            )
        )
        var model = ReactionBalancer(reaction: reaction)

        XCTAssertFalse(model.isBalanced)

        model.addReactant(.water)
        XCTAssertFalse(model.isBalanced)

        model.addProduct(.dihydrogen)
        XCTAssertFalse(model.isBalanced)

        model.addProduct(.dioxygen)
        XCTAssert(model.isBalanced)
    }

    func testReactionIsBalancedWhenMoleculeIsRemovedAfterAddingTooMany() {
        let reaction = BalancedReaction(
            reactants: .one(element: .init(molecule: .ammonia, coefficient: 1)),
            products: .two(
                first: .init(molecule: .methane, coefficient: 2),
                second: .init(molecule: .carbonDioxide, coefficient: 1)
            )
        )
        var model = ReactionBalancer(reaction: reaction)

        XCTAssertFalse(model.isBalanced)

        model.addReactant(.ammonia)
        model.addProduct(.methane)
        model.addProduct(.methane)
        model.addProduct(.carbonDioxide)
        XCTAssert(model.isBalanced)

        model.addProduct(.carbonDioxide)
        XCTAssertFalse(model.isBalanced)

        model.removeProduct(.carbonDioxide)
        XCTAssert(model.isBalanced)

        model.addReactant(.ammonia)
        XCTAssertFalse(model.isBalanced)

        model.removeReactant(.ammonia)
        XCTAssert(model.isBalanced)
    }

    func testRemovingAMoleculeBeforeItIsAddedHasNoEffect() {
        let reaction = BalancedReaction(
            reactants: .one(element: .init(molecule: .ammonia, coefficient: 1)),
            products: .one(element: .init(molecule: .carbonDioxide, coefficient: 1))
        )

        var model = ReactionBalancer(reaction: reaction)

        model.removeReactant(.ammonia)
        model.removeProduct(.carbonDioxide)

        model.addReactant(.ammonia)
        model.addProduct(.carbonDioxide)

        XCTAssert(model.isBalanced)
    }

    func testReactionWhichIsAnExactMultipleOfTheCorrectCoefficients() {
        let reaction = BalancedReaction(
            reactants: .one(element: .init(molecule: .ammonia, coefficient: 2)),
            products: .two(
                first: .init(molecule: .carbonDioxide, coefficient: 1),
                second: .init(molecule: .dihydrogen, coefficient: 3)
            )
        )

        var model = ReactionBalancer(reaction: reaction)

        XCTAssertFalse(model.isBalanced)
        XCTAssertFalse(model.isMultipleOfBalanced)

        model.add(.ammonia, to: .reactant, count: 2)
        model.add(.carbonDioxide, to: .product, count: 1)
        model.add(.dihydrogen, to: .product, count: 3)

        XCTAssert(model.isBalanced)
        XCTAssertFalse(model.isMultipleOfBalanced)

        model.add(.ammonia, to: .reactant, count: 2)
        model.add(.carbonDioxide, to: .product, count: 1)
        model.add(.dihydrogen, to: .product, count: 3)

        XCTAssertFalse(model.isBalanced)
        XCTAssert(model.isMultipleOfBalanced)
    }
}

private extension ReactionBalancer {
    mutating func add(
        _ molecule: BalancedReaction.Molecule,
        to elementType: BalancedReaction.ElementType,
        count: Int
    ) {
        (0..<count).forEach { _ in
            self.add(molecule, to: elementType)
        }
    }
}
