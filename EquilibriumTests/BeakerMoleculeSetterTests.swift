//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import Equilibrium

class BeakerMoleculeSetterTests: XCTestCase {

    func testSetterWithUnitCoefficientsAndEquilibriumConstant() {
        let grid = GridCoordinate.grid(cols: 10, rows: 10)
        let model = ReactionComponents(
            initialBeakerMolecules: molecules(
                a: Array(grid.prefix(30)),
                b: Array(grid.dropFirst(30).prefix(30))
            ),
            coefficients: .unit,
            equilibriumConstant: 1,
            shuffledBeakerCoords: grid,
            beakerGridSize: 100,
            initialGridMolecules: MoleculeValue(builder: { _ in []}),
            shuffledEquilibriumGrid: [],
            startTime: 0,
            equilibriumTime: 10,
            previousEquation: nil,
            previousMolecules: nil,
            rowsHaveChangeFromPrevious: nil
        )
        let concentration = model.equation.concentration

        XCTAssertEqual(model.moleculesC.coords(at: 0).count, 0)
        XCTAssertEqual(model.moleculesD.coords(at: 0).count, 0)

        XCTAssertEqual(model.moleculesC.coords(at: 10).count, 15)
        XCTAssertEqual(model.moleculesD.coords(at: 10).count, 15)

        XCTAssertEqual(model.moleculesC.coords(at: 7).count, (15 * concentration.productC.getValue(at: 7) / 0.15).roundedInt())
        XCTAssertEqual(model.moleculesD.coords(at: 7).count, (15 * concentration.productD.getValue(at: 7) / 0.15).roundedInt())

        XCTAssertEqual(model.getEffectiveReactants(at: 0).a.count, 30)
        XCTAssertEqual(model.getEffectiveReactants(at: 0).b.count, 30)

        XCTAssertEqual(model.getEffectiveReactants(at: 10).a.count, 15)
        XCTAssertEqual(model.getEffectiveReactants(at: 10).b.count, 15)
    }

    func testSetterWithNonUnitEquilibriumConstant() {
        let grid = GridCoordinate.grid(cols: 10, rows: 10)
        let model = ReactionComponents(
            initialBeakerMolecules: molecules(
                a: Array(grid.prefix(40)),
                b: Array(grid.dropFirst(40).prefix(30))
            ),
            coefficients: .unit,
            equilibriumConstant: 2,
            shuffledBeakerCoords: grid,
            beakerGridSize: 100,
            initialGridMolecules: MoleculeValue(builder: { _ in []}),
            shuffledEquilibriumGrid: [],
            startTime: 0,
            equilibriumTime: 10,
            previousEquation: nil,
            previousMolecules: nil,
            rowsHaveChangeFromPrevious: nil
        )

        XCTAssertEqual(model.moleculesC.coords(at: 0).count, 0)
        XCTAssertEqual(model.moleculesD.coords(at: 0).count, 0)

        XCTAssertEqual(model.moleculesC.coords(at: 10).count, 20)
        XCTAssertEqual(model.moleculesD.coords(at: 10).count, 20)

        XCTAssertEqual(model.getEffectiveReactants(at: 0).a.count, 40)
        XCTAssertEqual(model.getEffectiveReactants(at: 0).b.count, 30)

        XCTAssertEqual(model.getEffectiveReactants(at: 10).a.count, 20)
        XCTAssertEqual(model.getEffectiveReactants(at: 10).b.count, 10)
    }

    func testReverseSetterWithUnitCoefficientsAndEquilibriumConstant() {
        let grid = GridCoordinate.grid(cols: 10, rows: 10)
        let initA = Array(grid.prefix(30))
        let initB = Array(grid.dropFirst(30).prefix(30))

        let forwardModel = ReactionComponents(
            initialBeakerMolecules: molecules(a: initA, b: initB),
            coefficients: .unit,
            equilibriumConstant: 1,
            shuffledBeakerCoords: grid,
            beakerGridSize: 100,
            initialGridMolecules: MoleculeValue(builder: { _ in []}),
            shuffledEquilibriumGrid: [],
            startTime: 0,
            equilibriumTime: 10,
            previousEquation: nil,
            previousMolecules: nil,
            rowsHaveChangeFromPrevious: nil
        )

        let consolidatedReverseCoords = ReactionComponentsWrapper.consolidate(
            molecules: forwardModel.beakerMolecules,
            at: 10
        )
        let newC = consolidatedReverseCoords.value(for: .C) + Array(grid.suffix(15))
        let newD = consolidatedReverseCoords.value(for: .D) + Array(grid.dropLast(15).suffix(15))
        let updatedReverseCoords = consolidatedReverseCoords
            .updating(with: newC, for: .C)
            .updating(with: newD, for: .D)

        let reverseModel = ReactionComponents(
            initialBeakerMolecules: updatedReverseCoords,
            coefficients: .unit,
            equilibriumConstant: 1,
            shuffledBeakerCoords: grid,
            beakerGridSize: 100,
            initialGridMolecules: MoleculeValue(builder: { _ in []}),
            shuffledEquilibriumGrid: [],
            startTime: 11,
            equilibriumTime: 20,
            previousEquation: forwardModel.equation,
            previousMolecules: consolidatedReverseCoords,
            rowsHaveChangeFromPrevious: nil
        )

        XCTAssertEqual(reverseModel.moleculesA.coords(at: 11).count, 15)
        XCTAssertEqual(reverseModel.moleculesB.coords(at: 11).count, 15)

        assertSameElements(reverseModel.moleculesB.coords(at: 11), forwardModel.getEffectiveReactants(at: 10).b)

        XCTAssertEqual(reverseModel.moleculesA.coords(at: 20).count, 23, accuracy: 1)
        XCTAssertEqual(reverseModel.moleculesB.coords(at: 20).count, 23, accuracy: 1)

        XCTAssertEqual(reverseModel.getEffectiveProducts(at: 11).c.count, 30)
        XCTAssertEqual(reverseModel.getEffectiveProducts(at: 11).d.count, 30)

        XCTAssertEqual(reverseModel.getEffectiveProducts(at: 20).c.count, 23, accuracy: 2)
        XCTAssertEqual(reverseModel.getEffectiveProducts(at: 20).d.count, 23, accuracy: 2)

        let products = reverseModel.moleculesC.coordinates + reverseModel.moleculesD.coordinates
        func checkFinalReactants(finalCoords: [GridCoordinate], original: [GridCoordinate]) {
            original.forEach {
                XCTAssert(finalCoords.contains($0))
            }
            let newCoords = finalCoords.filter { !original.contains($0) }
            newCoords.forEach {
                XCTAssert(products.contains($0))
            }
        }

        checkFinalReactants(finalCoords: reverseModel.moleculesA.coords(at: 20), original: reverseModel.moleculesA.coordinates)
        checkFinalReactants(finalCoords: reverseModel.moleculesB.coords(at: 20), original: reverseModel.moleculesB.coordinates)
    }

    func testReverseSetterWithNonUnitCoefficientAndNoProductsAdded() {
        let grid = GridCoordinate.grid(cols: 10, rows: 10)

        let initA = Array(grid.prefix(30))
        let initB = Array(grid.dropFirst(30).prefix(30))

        let forwardModel = ReactionComponents(
            initialBeakerMolecules: molecules(a: initA, b: initB),
            coefficients: .unit,
            equilibriumConstant: 0.75,
            shuffledBeakerCoords: grid,
            beakerGridSize: 10,
            initialGridMolecules: MoleculeValue(builder: { _ in []}),
            shuffledEquilibriumGrid: [],
            startTime: 0,
            equilibriumTime: 10,
            previousEquation: nil,
            previousMolecules: nil,
            rowsHaveChangeFromPrevious: nil
        )

        let initReverseMolecules = ReactionComponentsWrapper.consolidate(molecules: forwardModel.beakerMolecules, at: 10)
        let reverseModel = ReactionComponents(
            initialBeakerMolecules: initReverseMolecules,
            coefficients: .unit,
            equilibriumConstant: 0.75,
            shuffledBeakerCoords: grid,
            beakerGridSize: 100,
            initialGridMolecules: MoleculeValue(builder: { _ in []}),
            shuffledEquilibriumGrid: [],
            startTime: 11,
            equilibriumTime: 20,
            previousEquation: forwardModel.equation,
            previousMolecules: initReverseMolecules,
            rowsHaveChangeFromPrevious: nil
        )

        assertSameElements(forwardModel.getEffectiveReactants(at: 11).a, reverseModel.moleculesA.coords(at: 11))
        assertSameElements(forwardModel.getEffectiveReactants(at: 11).b, reverseModel.moleculesB.coords(at: 11))

        let products = reverseModel.moleculesC.coordinates + reverseModel.moleculesD.coordinates
        func checkFinalReactants(finalCoords: [GridCoordinate], original: [GridCoordinate]) {
            original.forEach {
                XCTAssert(finalCoords.contains($0))
            }
            let newCoords = finalCoords.filter { !original.contains($0) }
            newCoords.forEach {
                XCTAssert(products.contains($0))
            }
        }

        checkFinalReactants(finalCoords: reverseModel.moleculesA.coords(at: 20), original: initReverseMolecules.reactantA)
        checkFinalReactants(finalCoords: reverseModel.moleculesB.coords(at: 20), original: initReverseMolecules.reactantB)
    }

    func testReverseSetterWithNonUnitCoefficientWhereProductsAreAdded() {
        let grid = GridCoordinate.grid(cols: 10, rows: 10)

        let initA = Array(grid.prefix(30))
        let initB = Array(grid.dropFirst(30).prefix(30))

        let forwardModel = ReactionComponents(
            initialBeakerMolecules: molecules(a: initA, b: initB),
            coefficients: .unit,
            equilibriumConstant: 0.75,
            shuffledBeakerCoords: grid,
            beakerGridSize: 100,
            initialGridMolecules: MoleculeValue(builder: { _ in []}),
            shuffledEquilibriumGrid: [],
            startTime: 0,
            equilibriumTime: 10,
            previousEquation: nil,
            previousMolecules: nil,
            rowsHaveChangeFromPrevious: nil
        )

        let finalProductGridCount = 30
        let extraCCount = finalProductGridCount - forwardModel.moleculesC.coordinates.count
        let extraDCount = finalProductGridCount - forwardModel.moleculesD.coordinates.count

        let finalFwdMolecules = ReactionComponentsWrapper.consolidate(molecules: forwardModel.beakerMolecules, at: 10)
        let updatedC = finalFwdMolecules.productC + Array(grid.suffix(extraCCount))
        let updatedD = finalFwdMolecules.productD +  Array(grid.dropLast(extraCCount).suffix(extraDCount))

        let initReverseMolecules = finalFwdMolecules
            .updating(with: updatedC, for: .C)
            .updating(with: updatedD, for: .D)

        let reverseModel = ReactionComponents(
            initialBeakerMolecules: initReverseMolecules,
            coefficients: .unit,
            equilibriumConstant: 0.75,
            shuffledBeakerCoords: grid,
            beakerGridSize: 100,
            initialGridMolecules: MoleculeValue(builder: { _ in []}),
            shuffledEquilibriumGrid: [],
            startTime: 11,
            equilibriumTime: 20,
            previousEquation: forwardModel.equation,
            previousMolecules: finalFwdMolecules,
            rowsHaveChangeFromPrevious: nil
        )

        assertSameElements(forwardModel.getEffectiveReactants(at: 11).a, reverseModel.moleculesA.coords(at: 11))
        assertSameElements(forwardModel.getEffectiveReactants(at: 11).b, reverseModel.moleculesB.coords(at: 11))

        let products = reverseModel.moleculesC.coordinates + reverseModel.moleculesD.coordinates
        func checkFinalReactants(finalCoords: [GridCoordinate], original: [GridCoordinate]) {
            original.forEach {
                XCTAssert(finalCoords.contains($0))
            }
            let newCoords = finalCoords.filter { !original.contains($0) }
            newCoords.forEach {
                XCTAssert(products.contains($0))
            }
        }

        checkFinalReactants(finalCoords: reverseModel.moleculesA.coords(at: 20), original: initReverseMolecules.reactantA)
        checkFinalReactants(finalCoords: reverseModel.moleculesB.coords(at: 20), original: initReverseMolecules.reactantB)
    }

    func testNonUnitCoefficientWhereThereIsANetDropInBeakerConcentration() {
        let coeffs = BalancedReactionCoefficients(reactantA: 3, reactantB: 2, productC: 1, productD: 2)

        let forwardWrapper = ReactionComponentsWrapper(
            coefficients: coeffs,
            equilibriumConstant: 10,
            beakerCols: 10,
            beakerRows: 10,
            maxBeakerRows: 10,
            dynamicGridCols: 10,
            dynamicGridRows: 10,
            startTime: 0,
            equilibriumTime: 10
        )
        forwardWrapper.increment(molecule: .A, count: 30)
        forwardWrapper.increment(molecule: .B, count: 30)

        let forwardModel = forwardWrapper.components
        let forwardReaction = forwardModel.equation

        let unitChange: CGFloat = 0.057
        let expectedConvergedA = 0.3 - (3 * unitChange)
        let expectedConvergedB = 0.3 - (2 * unitChange)

        let expectedConvergedAMolecules = (expectedConvergedA * 100).roundedInt()
        let expectedConvergedBMolecules = (expectedConvergedB * 100).roundedInt()

        let expectedCMolecules = (unitChange * 100).roundedInt()
        let expectedDMolecules = (2 * unitChange * 100).roundedInt()

        XCTAssertEqual(forwardReaction.equilibriumConcentrations.reactantA, expectedConvergedA, accuracy: 0.0001)
        XCTAssertEqual(forwardReaction.equilibriumConcentrations.reactantB, expectedConvergedB, accuracy: 0.0001)

        let convergedReactants = forwardModel.getEffectiveReactants(at: 10)

        let a0 = 30
        let a1 = forwardModel.moleculesA.coords(at: 10).count
        XCTAssertNotEqual(a0, a1)

        XCTAssertEqual(convergedReactants.a.count, expectedConvergedAMolecules)
        XCTAssertEqual(convergedReactants.b.count, expectedConvergedBMolecules)

        XCTAssertEqual(forwardModel.moleculesC.coords(at: 10).count, expectedCMolecules)
        XCTAssertEqual(forwardModel.moleculesD.coords(at: 10).count, expectedDMolecules)

        let reverseWrapper = ReactionComponentsWrapper(
            previous: forwardWrapper,
            startTime: 11,
            equilibriumTime: 20
        )
        let reverseModel = reverseWrapper.components

        XCTAssertEqual(reverseModel.moleculesA.coordinates, forwardModel.getEffectiveReactants(at: 10).a)
        XCTAssertEqual(reverseModel.moleculesB.coordinates, forwardModel.getEffectiveReactants(at: 10).b)
    }

    func testReverseReactionWhereThereIsANetIncreaseInConcentration() {
        let coeffs = BalancedReactionCoefficients(reactantA: 2, reactantB: 2, productC: 1, productD: 1)
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let forwardModel = ReactionComponents(
            initialBeakerMolecules: molecules(a: Array(grid.prefix(30)), b: Array(grid.dropFirst(30).prefix(30))),
            coefficients: coeffs,
            equilibriumConstant: 20,
            shuffledBeakerCoords: grid,
            beakerGridSize: 100,
            initialGridMolecules: MoleculeValue(builder: { _ in []}),
            shuffledEquilibriumGrid: [],
            startTime: 0,
            equilibriumTime: 10,
            previousEquation: nil,
            previousMolecules: nil,
            rowsHaveChangeFromPrevious: nil
        )

        let forwardUnitChange: CGFloat = 0.0822
        let finalReactant = 0.3 - (2 * forwardUnitChange)

        let forwardEquilibrium = forwardModel.equation.equilibriumConcentrations
        XCTAssertEqual(forwardEquilibrium.reactantA, finalReactant, accuracy: 0.001)
        XCTAssertEqual(forwardEquilibrium.reactantB, finalReactant, accuracy: 0.001)
        XCTAssertEqual(forwardEquilibrium.productC, forwardUnitChange, accuracy: 0.001)
        XCTAssertEqual(forwardEquilibrium.productD, forwardUnitChange, accuracy: 0.001)

        let forwardReactantCount = (finalReactant * 100).roundedInt()
        let forwardProductCount = (forwardUnitChange * 100).roundedInt()
        let dropInReactant = 30 - forwardReactantCount - forwardProductCount

        XCTAssertEqual(forwardModel.getEffectiveReactants(at: 10).a.count, forwardReactantCount)
        XCTAssertEqual(forwardModel.getEffectiveReactants(at: 10).b.count, forwardReactantCount)
        XCTAssertEqual(forwardModel.moleculesA.coords(at: 10).count, 30 - dropInReactant)
        XCTAssertEqual(forwardModel.moleculesB.coords(at: 10).count, 30 - dropInReactant)
        XCTAssertEqual(forwardModel.moleculesC.coords(at: 10).count, forwardProductCount)
        XCTAssertEqual(forwardModel.moleculesD.coords(at: 10).count, forwardProductCount)

        let consolidatedFwdMolecules = ReactionComponentsWrapper.consolidate(
            molecules: forwardModel.beakerMolecules,
            at: 10
        )

        let updatedC = consolidatedFwdMolecules.productC + grid.suffix(30 - forwardModel.moleculesC.coordinates.count)
        let extraD = grid.dropLast(30 - forwardModel.moleculesC.coordinates.count).suffix(30 - forwardModel.moleculesD.coordinates.count)
        let updatedD = consolidatedFwdMolecules.productD + extraD

        let initReverseMolecules = consolidatedFwdMolecules
            .updating(with: updatedC, for: .C)
            .updating(with: updatedD, for: .D)

        let reverseModel = ReactionComponents(
            initialBeakerMolecules: initReverseMolecules,
            coefficients: coeffs,
            equilibriumConstant: 20,
            shuffledBeakerCoords: grid,
            beakerGridSize: 100,
            initialGridMolecules: MoleculeValue(builder: { _ in []}),
            shuffledEquilibriumGrid: [],
            startTime: 11,
            equilibriumTime: 20,
            previousEquation: forwardModel.equation,
            previousMolecules: consolidatedFwdMolecules,
            rowsHaveChangeFromPrevious: nil
        )

        let reverseEquilibrium = reverseModel.equation.equilibriumConcentrations
        XCTAssertEqual(
            reverseModel.moleculesA.coords(at: 20).count,
            (reverseEquilibrium.reactantA * 100).roundedInt()
        )
        XCTAssertEqual(
            reverseModel.moleculesB.coords(at: 20).count,
            (reverseEquilibrium.reactantB * 100).roundedInt()
        )
        XCTAssertEqual(
            reverseModel.getEffectiveProducts(at: 20).c.count,
            (reverseEquilibrium.productC * 100).roundedInt()
        )
        XCTAssertEqual(
            reverseModel.getEffectiveProducts(at: 20).d.count,
            (reverseEquilibrium.productD * 100).roundedInt()
        )
    }

    private func assertSameElements(_ l: [GridCoordinate], _ r: [GridCoordinate]) {
        XCTAssertEqual(l.count, r.count)
        l.forEach {
            XCTAssertTrue(r.contains($0))
        }
    }

    private func molecules(a: [GridCoordinate], b: [GridCoordinate]) -> MoleculeValue<[GridCoordinate]> {
        MoleculeValue(
            reactantA: a,
            reactantB: b,
            productC: [],
            productD: []
        )
    }
}

private extension ReactionComponents {
    var fractions: MoleculeValue<FractionedCoordinates> {
        MoleculeValue(
            builder: { element in
                let molecules = beakerMolecules.first { $0.molecule == element }!
                return FractionedCoordinates(
                    coordinates: molecules.animatingMolecules.molecules.coords,
                    fractionToDraw: molecules.animatingMolecules.fractionToDraw
                )
            }
        )
    }

    func getEffectiveReactants(at x: CGFloat) -> (a: [GridCoordinate], b: [GridCoordinate]) {
        let products = moleculesC.coords(at: x) + moleculesD.coords(at: x)
        let effectiveA = moleculesA.coords(at: x).filter { !products.contains($0) }
        let effectiveB = moleculesB.coords(at: x).filter { !products.contains($0) }
        return (a: effectiveA, b: effectiveB)
    }

    func getEffectiveProducts(at x: CGFloat) -> (c: [GridCoordinate], d: [GridCoordinate]) {
        let reactants = moleculesA.coords(at: x) + moleculesB.coords(at: x)
        let effectiveC = moleculesC.coordinates.filter { !reactants.contains($0) }
        let effectiveD = moleculesD.coordinates.filter { !reactants.contains($0) }
        return (c: effectiveC, d: effectiveD)
    }

    var moleculesA: FractionedCoordinates {
        fractions.value(for: .A)
    }

    var moleculesB: FractionedCoordinates {
        fractions.value(for: .B)
    }

    var moleculesC: FractionedCoordinates {
        fractions.value(for: .C)
    }

    var moleculesD: FractionedCoordinates {
        fractions.value(for: .D)
    }
}
