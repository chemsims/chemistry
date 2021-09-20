//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class LimitingReagentComponentTests: XCTestCase {

    func testMolarityAndMolesOfLimitingReactant() {
        let reaction = reaction()
        let model = newModel(
            reaction: reaction,
            rows: 5,
            rowsToVolume: LinearEquation(x1: 0, y1: 0, x2: 10, y2: 0.5),
            initialState: nil
        )
        model.setRows(to: 10)
        XCTAssertEqual(model.volume, 0.5)

        model.state = .addingLimitingReactant

        model.addLimitingReactant(count: 20)

        XCTAssertEqual(model.limitingReactantMolarity, 0.2)
        XCTAssertEqual(model.equationData.limitingReactantMoles, 0.5 * 0.2)
    }

    func testExcessReactantTheoreticalMoles() {
        let coeff = 3
        let reaction = reaction(excessReactantCoefficient: coeff)
        let model = newModel(reaction: reaction)

        model.addLimitingReactant(count: 30)

        let expectedMoles = CGFloat(coeff) * model.equationData.limitingReactantMoles
        XCTAssertEqual(model.equationData.neededExcessReactantMoles, expectedMoles)
    }

    func testProductTheoreticalMolesAndMass() {
        let reaction = reaction(
            yield: 0.5,
            excessReactantCoefficient: 2,
            excessReactantMolecularMass: 50
        )
        let model = newModel(reaction: reaction)

        model.addLimitingReactant(count: 20)

        let expectedMass = model.equationData.limitingReactantMoles * CGFloat(reaction.product.molarMass)
        XCTAssertEqual(model.equationData.theoreticalProductMoles, model.equationData.limitingReactantMoles)
        XCTAssertEqual(model.equationData.theoreticalProductMass, expectedMass)
    }

    func testActualProductMolesAndMass() {
        let reaction = reaction(
            yield: 0.5,
            excessReactantCoefficient: 2,
            productMolecularMass: 50
        )
        let model = newModel(reaction: reaction)

        model.addLimitingReactant(count: 20)

        let initialMass = model.equationData.actualProductMass.getY(at: 0)
        let finalMass = model.equationData.actualProductMass.getY(at: 1)

        XCTAssertEqual(initialMass, 0)
        XCTAssertEqual(finalMass, model.equationData.theoreticalProductMass * 0.5)

        let initialMoles = model.equationData.actualProductMoles.getY(at: 0)
        let finalMoles = model.equationData.actualProductMoles.getY(at: 1)
        XCTAssertEqual(initialMoles, 0)
        XCTAssertEqual(finalMoles, finalMass / CGFloat(reaction.product.molarMass))
    }

    func testActualReactantMolesAndMass() {
        let coeff = 3
        let reaction = reaction(
            yield: 0.5,
            excessReactantCoefficient: coeff,
            productMolecularMass: 50
        )
        let model = newModel(reaction: reaction)

        model.addLimitingReactant(count: 20)

        let initialMoles = model.equationData.reactingExcessReactantMoles.getY(at: 0)
        let finalMoles = model.equationData.reactingExcessReactantMoles.getY(at: 1)

        let finalProductMoles = model.equationData.actualProductMoles.getY(at: 1)
        let expectedFinalMoles = CGFloat(coeff) * finalProductMoles

        XCTAssertEqual(initialMoles, 0)
        XCTAssertEqual(finalMoles, expectedFinalMoles)

        let initialMass = model.equationData.reactingExcessReactantMass.getY(at: 0)
        let finalMass = model.equationData.reactingExcessReactantMass.getY(at: 1)

        XCTAssertEqual(initialMass, 0)
        XCTAssertEqual(finalMass, finalMoles * CGFloat(reaction.excessReactant.molarMass))
    }

    func testCoordsArePopulatedWhenAddingLimitingReactant() {
        let model = newModel(reaction: reaction())

        model.addLimitingReactant(count: 10)
        XCTAssertEqual(Set(model.limitingReactantCoords).count, 10)

        model.addLimitingReactant(count: 5)
        XCTAssertEqual(Set(model.limitingReactantCoords).count, 15)
    }

    func testCoordsArePopulatedWhenAddingExcessReactant() {
        let model = newModel(reaction: reaction())

        model.addLimitingReactant(count: 10)
        model.addExcessReactant(count: 10)

        let limitingCoordsSet = Set(model.limitingReactantCoords)
        let excessCoordsSet = Set(model.excessReactantCoords)

        XCTAssertEqual(excessCoordsSet.count, 10)
        XCTAssertEqual(limitingCoordsSet.intersection(excessCoordsSet).count, 0)
    }


    private func newModel(
        reaction: LimitingReagentReaction,
        rows: Int = 10,
        cols: Int = 10,
        rowsToVolume: Equation = IdentityEquation(),
        initialState: LimitingReagentComponents.State? = .addingLimitingReactant
    ) -> LimitingReagentComponents {
        let model = LimitingReagentComponents(
            reaction: reaction,
            initialRows: rows,
            cols: cols,
            rowsToVolume: rowsToVolume
        )
        if let initialState = initialState {
            model.state = initialState
        }
        return model
    }

    private func reaction(
        yield: CGFloat = 1,
        excessReactantCoefficient: Int = 1,
        excessReactantMolecularMass: Int = 1,
        productMolecularMass: Int = 1
    ) -> LimitingReagentReaction {
        LimitingReagentReaction(
            yield: yield,
            limitingReactant: .init(
                name: "",
                state: .aqueous,
                color: .red
            ),
            excessReactant: .init(
                name: "",
                state: .aqueous,
                color: .red,
                coefficient: excessReactantCoefficient,
                molarMass: excessReactantMolecularMass
            ),
            product: .init(
                name: "",
                state: .aqueous,
                color: .red,
                molarMass: productMolecularMass
            ),
            firstExtraProduct: nil,
            secondExtraProduct: nil
        )
    }
}
