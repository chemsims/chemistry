//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class LimitingReagentComponentTests: XCTestCase {

    func testMolarityAndMolesOfLimitingReactant() {
        let reaction = LimitingReagentReaction(
            yield: 0.5,
            excessReactantCoefficient: 1,
            excessReactantMolecularMass: 1,
            productMolecularMass: 1
        )
        let model = LimitingReagentComponents(
            reaction: reaction,
            initialRows: 5,
            cols: 10,
            rowsToVolume: LinearEquation(x1: 0, y1: 0, x2: 10, y2: 0.5)
        )
        model.rows = 10
        XCTAssertEqual(model.volume, 0.5)

        model.addLimitingReactant(count: 20)

        XCTAssertEqual(model.limitingReactantMolarity, 0.2)
        XCTAssertEqual(model.limitingReactantMoles, 0.5 * 0.2)
    }

    func testExcessReactantTheoreticalMoles() {
        let coeff = 3
        let reaction = LimitingReagentReaction(
            yield: 0.5,
            excessReactantCoefficient: coeff,
            excessReactantMolecularMass: 1,
            productMolecularMass: 1
        )
        let model = LimitingReagentComponents(
            reaction: reaction,
            initialRows: 10,
            cols: 10
        )

        model.addLimitingReactant(count: 30)

        let expectedMoles = CGFloat(coeff) * model.limitingReactantMoles
        XCTAssertEqual(model.excessReactantTheoreticalMoles, expectedMoles)
    }

    func testProductTheoreticalMolesAndMass() {
        let reaction = LimitingReagentReaction(
            yield: 0.5,
            excessReactantCoefficient: 2,
            excessReactantMolecularMass: 1,
            productMolecularMass: 50
        )
        let model = LimitingReagentComponents(
            reaction: reaction,
            initialRows: 10,
            cols: 10
        )

        model.addLimitingReactant(count: 20)

        let expectedMass = model.limitingReactantMoles * reaction.productMolecularMass
        XCTAssertEqual(model.productTheoreticalMoles, model.limitingReactantMoles)
        XCTAssertEqual(model.productTheoreticalMass, expectedMass)
    }

    func testActualProductMolesAndMass() {
        let reaction = LimitingReagentReaction(
            yield: 0.5,
            excessReactantCoefficient: 2,
            excessReactantMolecularMass: 1,
            productMolecularMass: 50
        )
        let model = LimitingReagentComponents(
            reaction: reaction,
            initialRows: 10,
            cols: 10
        )

        model.addLimitingReactant(count: 20)

        let initialMass = model.productActualMass.getY(at: 0)
        let finalMass = model.productActualMass.getY(at: 1)

        XCTAssertEqual(initialMass, 0)
        XCTAssertEqual(finalMass, model.productTheoreticalMass * 0.5)

        let initialMoles = model.productActualMoles.getY(at: 0)
        let finalMoles = model.productActualMoles.getY(at: 1)
        XCTAssertEqual(initialMoles, 0)
        XCTAssertEqual(finalMoles, finalMass / reaction.productMolecularMass)
    }

    func testActualReactantMolesAndMass() {
        let coeff = 3
        let reaction = LimitingReagentReaction(
            yield: 0.5,
            excessReactantCoefficient: coeff,
            excessReactantMolecularMass: 1,
            productMolecularMass: 50
        )
        let model = LimitingReagentComponents(
            reaction: reaction,
            initialRows: 10,
            cols: 10
        )

        model.addLimitingReactant(count: 20)

        let initialMoles = model.excessReactantActualMoles.getY(at: 0)
        let finalMoles = model.excessReactantActualMoles.getY(at: 1)

        let finalProductMoles = model.productActualMoles.getY(at: 1)
        let expectedFinalMoles = CGFloat(coeff) * finalProductMoles

        XCTAssertEqual(initialMoles, 0)
        XCTAssertEqual(finalMoles, expectedFinalMoles)

        let initialMass = model.excessReactantActualMass.getY(at: 0)
        let finalMass = model.excessReactantActualMass.getY(at: 1)

        XCTAssertEqual(initialMass, 0)
        XCTAssertEqual(finalMass, finalMoles * reaction.excessReactantMolecularMass)
    }
}
