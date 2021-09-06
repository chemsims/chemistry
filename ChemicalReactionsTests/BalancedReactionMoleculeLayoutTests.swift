//
// Reactions App
//

import XCTest
@testable import ChemicalReactions

class BalancedReactionMoleculeLayoutTests: XCTestCase {
    func testSingleMoleculePosition() {
        let rect = CGRect(
            origin: .init(x: 20, y: 40),
            size: .init(width: 200, height: 60)
        )
        let model = BalancedReactionMoleculeGridLayout(
            rect: rect,
            reactants: .single,
            products: .single
        )

        let expectedReactant = CGPoint(x: 120, y: 55)
        XCTAssertEqual(model.firstReactantPosition, expectedReactant)

        let expectedProduct = CGPoint(x: 120, y: 85)
        XCTAssertEqual(model.firstProductPosition, expectedProduct)

        XCTAssertNil(model.secondReactantPosition)
        XCTAssertNil(model.secondProductPosition)
    }

    func testDoubleMoleculePosition() {
        let rect = CGRect(
            origin: .init(x: 20, y: 40),
            size: .init(width: 200, height: 60)
        )
        let model = BalancedReactionMoleculeGridLayout(
            rect: rect,
            reactants: .double,
            products: .double
        )

        let expectedFirstReactant = CGPoint(x: 70, y: 55)
        let expectedSecondReactant = CGPoint(x: 170, y: 55)
        XCTAssertEqual(model.firstReactantPosition, expectedFirstReactant)
        XCTAssertEqual(model.secondReactantPosition, expectedSecondReactant)

        let expectedFirstProduct = CGPoint(x: 70, y: 85)
        let expectedSecondProduct = CGPoint(x: 170, y: 85)
        XCTAssertEqual(model.firstProductPosition, expectedFirstProduct)
        XCTAssertEqual(model.secondProductPosition, expectedSecondProduct)
    }
}
