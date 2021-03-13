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

    func testReverseSetterWithUnitCoefficientsAndEquilibriumConstant() {
        let forwardReaction = BalancedReactionEquations(coefficients: .unit, equilibriumConstant: 1, a0: 0.3, b0: 0.3, convergenceTime: 10)

        let grid = GridCoordinate.grid(cols: 10, rows: 10)
        let initA = Array(grid.prefix(30))
        let initB = Array(grid.dropFirst(30).prefix(30))

        let forwardGrid = BeakerMoleculesSetter(
            totalMolecules: 100,
            moleculesA: initA,
            moleculesB: initB,
            reactionEquation: forwardReaction
        )

        let reaction = BalancedReactionEquations(
            forwardReaction: forwardReaction,
            reverseInput: ReverseReactionInput(
                c0: 0.3, d0: 0.3, startTime: 11, convergenceTime: 20
            )
        )

        let initC = Array(initA.prefix(8) + initB.prefix(7) + grid.suffix(15))
        let initD = Array(initA.dropFirst(8).prefix(7) + initB.dropFirst(7).prefix(8) + grid.dropLast(15).suffix(15))
        let model = ReverseBeakerMoleculeSetter(
            reverseReaction: reaction,
            startTime: 11,
            forwardBeaker: forwardGrid,
            cMolecules: initC,
            dMolecules: initD
        )

        XCTAssertEqual(model.aMolecules.coords(at: 11).count, 15)
        XCTAssertEqual(model.bMolecules.coords(at: 11).count, 15)

        assertSameElements(model.bMolecules.coords(at: 11), forwardGrid.getEffectiveReactants(at: 10).b)

        XCTAssertEqual(model.aMolecules.coords(at: 20).count, 23, accuracy: 1)
        XCTAssertEqual(model.bMolecules.coords(at: 20).count, 23, accuracy: 1)

        XCTAssertEqual(model.getEffectiveProducts(at: 11).c.count, 30)
        XCTAssertEqual(model.getEffectiveProducts(at: 11).d.count, 30)

        XCTAssertEqual(model.getEffectiveProducts(at: 20).c.count, 23, accuracy: 2)
        XCTAssertEqual(model.getEffectiveProducts(at: 20).d.count, 23, accuracy: 2)

        let products = model.cMolecules + model.dMolecules
        func checkFinalReactants(finalCoords: [GridCoordinate], original: [GridCoordinate]) {
            original.forEach {
                XCTAssert(finalCoords.contains($0))
            }
            let newCoords = finalCoords.filter { !original.contains($0) }
            newCoords.forEach {
                XCTAssert(products.contains($0))
            }
        }

        checkFinalReactants(finalCoords: model.aMolecules.coords(at: 20), original: model.originalAMolecules)
        checkFinalReactants(finalCoords: model.bMolecules.coords(at: 20), original: model.originalBMolecules)
    }

    func testReverseSetterWithNonUnitCoefficientAndNoProductsAdded() {
        let forwardReaction = BalancedReactionEquations(coefficients: .unit, equilibriumConstant: 0.75, a0: 0.3, b0: 0.3, convergenceTime: 10)

        let grid = GridCoordinate.grid(cols: 10, rows: 10)

        let initA = Array(grid.prefix(30))
        let initB = Array(grid.dropFirst(30).prefix(30))
        let forwardGrid = BeakerMoleculesSetter(
            totalMolecules: 100,
            moleculesA: initA,
            moleculesB: initB,
            reactionEquation: forwardReaction
        )


        let c0 = forwardReaction.productC.getY(at: 10)
        let d0 = forwardReaction.productC.getY(at: 10)

        let reverseReaction = BalancedReactionEquations(
            forwardReaction: forwardReaction,
            reverseInput: ReverseReactionInput(c0: c0, d0: d0, startTime: 11, convergenceTime: 20)
        )
        let reverseGrid = ReverseBeakerMoleculeSetter(
            reverseReaction: reverseReaction,
            startTime: 11,
            forwardBeaker: forwardGrid,
            cMolecules: forwardGrid.c.coordinates,
            dMolecules: forwardGrid.d.coordinates
        )

        assertSameElements(forwardGrid.getEffectiveReactants(at: 11).a, reverseGrid.aMolecules.coords(at: 11))
        assertSameElements(forwardGrid.getEffectiveReactants(at: 11).b, reverseGrid.bMolecules.coords(at: 11))

        let products = reverseGrid.cMolecules + reverseGrid.dMolecules
        func checkFinalReactants(finalCoords: [GridCoordinate], original: [GridCoordinate]) {
            original.forEach {
                XCTAssert(finalCoords.contains($0))
            }
            let newCoords = finalCoords.filter { !original.contains($0) }
            newCoords.forEach {
                XCTAssert(products.contains($0))
            }
        }

        checkFinalReactants(finalCoords: reverseGrid.aMolecules.coords(at: 20), original: reverseGrid.originalAMolecules)
        checkFinalReactants(finalCoords: reverseGrid.bMolecules.coords(at: 20), original: reverseGrid.originalBMolecules)
    }

    func testReverseSetterWithNonUnitCoefficientWhereProductsAreAdded() {
        let forwardReaction = BalancedReactionEquations(coefficients: .unit, equilibriumConstant: 0.75, a0: 0.3, b0: 0.3, convergenceTime: 10)

        let grid = GridCoordinate.grid(cols: 10, rows: 10)

        let initA = Array(grid.prefix(30))
        let initB = Array(grid.dropFirst(30).prefix(30))
        let forwardGrid = BeakerMoleculesSetter(
            totalMolecules: 100,
            moleculesA: initA,
            moleculesB: initB,
            reactionEquation: forwardReaction
        )

        let reverseReaction = BalancedReactionEquations(
            forwardReaction: forwardReaction,
            reverseInput: ReverseReactionInput(c0: 0.3, d0: 0.3, startTime: 11, convergenceTime: 20)
        )
        let finalProductGridCount = GridMoleculesUtil.gridCount(for: 0.3, gridSize: 100)
        let extraCCount = finalProductGridCount - forwardGrid.cMolecules.count
        let extraDCount = finalProductGridCount - forwardGrid.dMolecules.count

        let reverseGrid = ReverseBeakerMoleculeSetter(
            reverseReaction: reverseReaction,
            startTime: 11,
            forwardBeaker: forwardGrid,
            cMolecules: forwardGrid.c.coordinates + Array(grid.suffix(extraCCount)),
            dMolecules: forwardGrid.d.coordinates + Array(grid.dropLast(extraCCount).suffix(extraDCount))
        )

        assertSameElements(forwardGrid.getEffectiveReactants(at: 11).a, reverseGrid.aMolecules.coords(at: 11))
        assertSameElements(forwardGrid.getEffectiveReactants(at: 11).b, reverseGrid.bMolecules.coords(at: 11))

        let products = reverseGrid.cMolecules + reverseGrid.dMolecules
        func checkFinalReactants(finalCoords: [GridCoordinate], original: [GridCoordinate]) {
            original.forEach {
                XCTAssert(finalCoords.contains($0))
            }
            let newCoords = finalCoords.filter { !original.contains($0) }
            newCoords.forEach {
                XCTAssert(products.contains($0))
            }
        }

        checkFinalReactants(finalCoords: reverseGrid.aMolecules.coords(at: 20), original: reverseGrid.originalAMolecules)
        checkFinalReactants(finalCoords: reverseGrid.bMolecules.coords(at: 20), original: reverseGrid.originalBMolecules)
    }

    func testNonUnitCoefficientWhereThereIsANetDropInBeakerConcentration() {
        let coeffs = BalancedReactionCoefficients(reactantA: 3, reactantB: 2, productC: 1, productD: 2)
        let forwardReaction = BalancedReactionEquations(coefficients: coeffs, equilibriumConstant: 10, a0: 0.3, b0: 0.3, convergenceTime: 10)

        let grid = GridCoordinate.grid(cols: 10, rows: 10)
        let model = BeakerMoleculesSetter(
            totalMolecules: 100,
            moleculesA: Array(grid.prefix(30)),
            moleculesB: Array(grid.dropFirst(30).prefix(30)),
            reactionEquation: forwardReaction
        )

        let unitChange: CGFloat = 0.057
        let expectedConvergedA = 0.3 - (3 * unitChange)
        let expectedConvergedB = 0.3 - (2 * unitChange)

        let expectedConvergedAMolecules = (expectedConvergedA * 100).roundedInt()
        let expectedConvergedBMolecules = (expectedConvergedB * 100).roundedInt()

        let expectedCMolecules = (unitChange * 100).roundedInt()
        let expectedDMolecules = (2 * unitChange * 100).roundedInt()

        XCTAssertEqual(forwardReaction.convergenceA, expectedConvergedA, accuracy: 0.0001)
        XCTAssertEqual(forwardReaction.convergenceB, expectedConvergedB, accuracy: 0.0001)

        let convergedReactants = model.getEffectiveReactants(at: 10)

        let a0 = model.underlyingAMolecules.count
        let a1 = model.moleculesA.coords(at: 10).count
        XCTAssertNotEqual(a0, a1)

        XCTAssertEqual(convergedReactants.a.count, expectedConvergedAMolecules)
        XCTAssertEqual(convergedReactants.b.count, expectedConvergedBMolecules)

        XCTAssertEqual(model.c.coords(at: 10).count, expectedCMolecules)
        XCTAssertEqual(model.d.coords(at: 10).count, expectedDMolecules)


        let reverseReaction = BalancedReactionEquations(
            forwardReaction: forwardReaction,
            reverseInput: ReverseRe  actionInput(
                c0: unitChange,
                d0: 2 * unitChange,
                startTime: 11,
                convergenceTime: 20
            )
        )
        let reverseModel = ReverseBeakerMoleculeSetter(
            reverseReaction: reverseReaction,
            startTime: 11,
            forwardBeaker: model,
            cMolecules: model.cMolecules,
            dMolecules: model.dMolecules
        )


        XCTAssertEqual(reverseModel.aMolecules.coordinates, model.getEffectiveReactants(at: 10).a)
        XCTAssertEqual(reverseModel.bMolecules.coordinates, model.getEffectiveReactants(at: 10).b)
    }

    private func assertSameElements(_ l: [GridCoordinate], _ r: [GridCoordinate]) {
        XCTAssertEqual(l.count, r.count)
        l.forEach {
            XCTAssertTrue(r.contains($0))
        }
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
        let effectiveA = moleculesA.coords(at: x).filter { !products.contains($0) }
        let effectiveB = moleculesB.coords(at: x).filter { !products.contains($0) }
        return (a: effectiveA, b: effectiveB)
    }
}

extension ReverseBeakerMoleculeSetter {
    func getEffectiveProducts(at x: CGFloat) -> (c: [GridCoordinate], d: [GridCoordinate]) {
        let reactants = aMolecules.coords(at: x) + bMolecules.coords(at: x)
        let effectiveC = cMolecules.filter { !reactants.contains($0) }
        let effectiveD = dMolecules.filter { !reactants.contains($0) }
        return (c: effectiveC, d: effectiveD)
    }
}
