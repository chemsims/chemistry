//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import reactions_equilibrium

class BeakerMoleculeSetterTests: XCTestCase {

    func testSetterWithUnitCoefficientsAndEquilibriumConstant() {
        let reaction = BalancedReactionEquations(coefficients: .unit, equilibriumConstant: 1, a0: 0.3, b0: 0.3, convergenceTime: 10)
        let grid = GridCoordinate.grid(cols: 10, rows: 10)
        let model = BeakerMoleculesSetter(
            totalMolecules: 100,
            endOfReactionTime: 10,
            moleculesA: Array(grid.prefix(30)),
            moleculesB: Array(grid.dropFirst(30).prefix(30)),
            reactionEquation: reaction
        )

        XCTAssertEqual(model.c.coords(at: 0).count, 0)
        XCTAssertEqual(model.d.coords(at: 0).count, 0)

        XCTAssertEqual(model.c.coords(at: 10).count, 15)
        XCTAssertEqual(model.d.coords(at: 10).count, 15)

        XCTAssertEqual(model.c.coords(at: 7).count, (15 * reaction.productC.getY(at: 7) / 0.15).roundedInt())
        XCTAssertEqual(model.d.coords(at: 7).count, (15 * reaction.productD.getY(at: 7) / 0.15).roundedInt())

        XCTAssertEqual(model.getEffectiveReactants(at: 0).a.count, 30)
        XCTAssertEqual(model.getEffectiveReactants(at: 0).b.count, 30)

        XCTAssertEqual(model.getEffectiveReactants(at: 10).a.count, 15)
        XCTAssertEqual(model.getEffectiveReactants(at: 10).b.count, 15)
    }

    func testSetterWithNonUnitEquilibriumConstant() {
        let reaction = BalancedReactionEquations(
            coefficients: BalancedReactionCoefficients(
                reactantA: 1,
                reactantB: 1,
                productC: 1,
                productD: 1
            ),
            equilibriumConstant: 2,
            a0: 0.4,
            b0: 0.3,
            convergenceTime: 10
        )
        let grid = GridCoordinate.grid(cols: 10, rows: 10)
        let model = BeakerMoleculesSetter(
            totalMolecules: 100,
            endOfReactionTime: 10,
            moleculesA: Array(grid.prefix(40)),
            moleculesB: Array(grid.dropFirst(40).prefix(30)),
            reactionEquation: reaction
        )

        XCTAssertEqual(model.c.coords(at: 0).count, 0)
        XCTAssertEqual(model.d.coords(at: 0).count, 0)

        XCTAssertEqual(model.c.coords(at: 10).count, 20)
        XCTAssertEqual(model.d.coords(at: 10).count, 20)

        XCTAssertEqual(model.getEffectiveReactants(at: 0).a.count, 40)
        XCTAssertEqual(model.getEffectiveReactants(at: 0).b.count, 30)

        XCTAssertEqual(model.getEffectiveReactants(at: 10).a.count, 20)
        XCTAssertEqual(model.getEffectiveReactants(at: 10).b.count, 10)
    }
}

// TODO - remove this extension when the model exposes FractionCoordinates
extension BeakerMoleculesSetter {
    var c: FractionedCoordinates {
        FractionedCoordinates(coordinates: cMolecules, fractionToDraw: cFractionToDraw)
    }

    var d: FractionedCoordinates {
        FractionedCoordinates(coordinates: dMolecules, fractionToDraw: dFractionToDraw)
    }

    func getEffectiveReactants(at x: CGFloat) -> (a: [GridCoordinate], b: [GridCoordinate]) {
        let products = c.coords(at: x) + d.coords(at: x)
        let effectiveA = moleculesA.filter { !products.contains($0) }
        let effectiveB = moleculesB.filter { !products.contains($0) }
        return (a: effectiveA, b: effectiveB)
    }
}
