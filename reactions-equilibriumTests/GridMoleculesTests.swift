//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import reactions_equilibrium

class GridMoleculesTests: XCTestCase {

    func testForwardGridMolecules() {
        let componentWrapper = ReactionComponentsWrapper(
            coefficients: .unit,
            equilibriumConstant: 1,
            beakerCols: 10,
            beakerRows: 10,
            maxBeakerRows: 10,
            dynamicGridCols: 10,
            dynamicGridRows: 10,
            startTime: 0,
            equilibriumTime: 10,
            maxC: 1
        )

        var reaction: MoleculeValue<Equation> {
            componentWrapper.components.equation.concentration
        }

        func increment(molecule: AqueousMolecule) {
            componentWrapper.increment(molecule: molecule, count: 50)
        }

        var aGrid: FractionedCoordinates { componentWrapper.components.equilibriumGrid.reactantA }
        var bGrid: FractionedCoordinates { componentWrapper.components.equilibriumGrid.reactantB }
        var cGrid: FractionedCoordinates { componentWrapper.components.equilibriumGrid.productC }
        var dGrid: FractionedCoordinates { componentWrapper.components.equilibriumGrid.productD }

        XCTAssertEqual(aGrid.coordinates, [])
        XCTAssertEqual(bGrid.coordinates, [])
        XCTAssertEqual(cGrid.coordinates, [])
        XCTAssertEqual(dGrid.coordinates, [])

        increment(molecule: .A)
        increment(molecule: .B)
        XCTAssertEqual(aGrid.coordinates.count, gridCountFor(0.5))
        XCTAssertEqual(bGrid.coordinates.count, gridCountFor(0.5))
        XCTAssertEqual(cGrid.coordinates.count, gridCountFor(0.25))
        XCTAssertEqual(dGrid.coordinates.count, gridCountFor(0.25))

        func expectedFraction(_ c: CGFloat, _ initC: CGFloat) -> CGFloat {
            CGFloat(gridCountFor(c)) / CGFloat(gridCountFor(initC))
        }

        XCTAssertEqual(aGrid.fractionToDraw.getY(at: 0), 1)
        XCTAssertEqual(aGrid.fractionToDraw.getY(at: 3), expectedFraction(reaction.reactantA.getY(at: 3), 0.5), accuracy: 0.01)
        XCTAssertEqual(aGrid.fractionToDraw.getY(at: 5), expectedFraction(reaction.reactantA.getY(at: 5), 0.5), accuracy: 0.01)
        XCTAssertEqual(aGrid.fractionToDraw.getY(at: 10), expectedFraction(reaction.reactantA.getY(at: 10), 0.5), accuracy: 0.00001)

        XCTAssertEqual(bGrid.fractionToDraw.getY(at: 0), 1)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: 3), expectedFraction(reaction.reactantB.getY(at: 3), 0.5), accuracy: 0.01)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: 5), expectedFraction(reaction.reactantB.getY(at: 5), 0.5), accuracy: 0.01)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: 10), expectedFraction(reaction.reactantB.getY(at: 10), 0.5), accuracy: 0.01)

        XCTAssertEqual(cGrid.fractionToDraw.getY(at: 0), 0)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: 3), expectedFraction(reaction.productC.getY(at: 3), 0.25), accuracy: 0.01)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: 5), expectedFraction(reaction.productC.getY(at: 5), 0.25), accuracy: 0.015)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: 10), 1)

        XCTAssertEqual(dGrid.fractionToDraw.getY(at: 0), 0)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: 3), expectedFraction(reaction.productD.getY(at: 3), 0.25), accuracy: 0.01)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: 5), expectedFraction(reaction.productD.getY(at: 5), 0.25), accuracy: 0.015)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: 10), 1)
    }

    func testReverseGridMolecules() {
        let tAddProd: CGFloat = 11
        let tEnd: CGFloat = 20

        let forwardModel = ReactionComponentsWrapper(
            coefficients: .unit,
            equilibriumConstant: 1,
            beakerCols: 10,
            beakerRows: 10,
            maxBeakerRows: 10,
            dynamicGridCols: 10,
            dynamicGridRows: 10,
            startTime: 0,
            equilibriumTime: 10,
            maxC: 1
        )
        forwardModel.increment(molecule: .A, count: 30)
        forwardModel.increment(molecule: .B, count: 30)

        let reverseModel = ReactionComponentsWrapper(
            previous: forwardModel,
            startTime: tAddProd,
            equilibriumTime: tEnd
        )

        func incrementProducts() {
            reverseModel.increment(molecule: .C, count: 15)
            reverseModel.increment(molecule: .D, count: 15)
        }

        var aGrid: FractionedCoordinates { reverseModel.components.equilibriumGrid.reactantA }
        var bGrid: FractionedCoordinates { reverseModel.components.equilibriumGrid.reactantB }
        var cGrid: FractionedCoordinates { reverseModel.components.equilibriumGrid.productC }
        var dGrid: FractionedCoordinates { reverseModel.components.equilibriumGrid.productD }


        func testStartOfReactionBeforeProductIsAdded(reverseCoords: FractionedCoordinates, expectedForwardCoords: [GridCoordinate]) {
            XCTAssertEqual(reverseCoords.coordinates, expectedForwardCoords)
            XCTAssertEqual(reverseCoords.fractionToDraw.getY(at: tAddProd), 1, accuracy: 0.0001)
            XCTAssertEqual(reverseCoords.fractionToDraw.getY(at: tEnd), 1, accuracy: 0.0001)
        }

        let expectedInitA = Array(forwardModel.components.equilibriumGrid.reactantA.coords(at: 10))
        let expectedInitB = Array(forwardModel.components.equilibriumGrid.reactantB.coords(at: 10))

        testStartOfReactionBeforeProductIsAdded(reverseCoords: aGrid, expectedForwardCoords: expectedInitA)
        testStartOfReactionBeforeProductIsAdded(reverseCoords: bGrid, expectedForwardCoords: expectedInitB)
        testStartOfReactionBeforeProductIsAdded(reverseCoords: cGrid, expectedForwardCoords: forwardModel.components.equilibriumGrid.productC.coordinates)
        testStartOfReactionBeforeProductIsAdded(reverseCoords: dGrid, expectedForwardCoords: forwardModel.components.equilibriumGrid.productD.coordinates)

        incrementProducts()

        let equation = reverseModel.components.equation
        let initC = equation.initialConcentrations
        let eqC = equation.equilibriumConcentrations
        XCTAssertEqual(aGrid.coordinates.count, gridCountFor(eqC.reactantA))
        XCTAssertEqual(bGrid.coordinates.count, gridCountFor(eqC.reactantB))
        XCTAssertEqual(cGrid.coordinates.count, gridCountFor(initC.productC))
        XCTAssertEqual(dGrid.coordinates.count, gridCountFor(initC.productD))

        XCTAssertEqual(aGrid.coords(at: tAddProd), forwardModel.components.equilibriumGrid.reactantA.coords(at: 10))
        XCTAssertEqual(bGrid.coords(at: tAddProd), forwardModel.components.equilibriumGrid.reactantB.coords(at: 10))

        XCTAssertEqual(aGrid.fractionToDraw.getY(at: tAddProd), CGFloat(gridCountFor(0.15)) / CGFloat(gridCountFor(eqC.reactantA)), accuracy: 0.01)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: tAddProd), CGFloat(gridCountFor(0.15)) / CGFloat(gridCountFor(eqC.reactantB)), accuracy: 0.0001)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: tAddProd), 1, accuracy: 0.0001)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: tAddProd), 1, accuracy: 0.0001)

        XCTAssertEqual(aGrid.fractionToDraw.getY(at: tEnd), 1)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: tEnd), 1)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: tEnd), CGFloat(gridCountFor(eqC.productC)) / CGFloat(gridCountFor(initC.productC)), accuracy: 0.0001)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: tEnd), CGFloat(gridCountFor(eqC.productD)) / CGFloat(gridCountFor(initC.productD)), accuracy: 0.0001)

        let dt = tEnd - tAddProd
        let tMid = tAddProd + (dt / 3)
        func expectedFraction(_ underlying: Equation, _ maxC: CGFloat) -> CGFloat {
            CGFloat(gridCountFor(underlying.getY(at: tMid))) / CGFloat(gridCountFor(maxC))
        }

        let reverseReaction = equation.concentration
        XCTAssertEqual(aGrid.fractionToDraw.getY(at: tMid), expectedFraction(reverseReaction.reactantA, eqC.reactantA), accuracy: 0.015)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: tMid), expectedFraction(reverseReaction.reactantA, eqC.reactantB), accuracy: 0.015)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: tMid), expectedFraction(reverseReaction.productC, initC.productC), accuracy: 0.015)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: tMid), expectedFraction(reverseReaction.productD, initC.productC), accuracy: 0.015)
    }

    func testAddingSecondElementBeforeFirstElement() {
        let model = ReactionComponentsWrapper(
            coefficients: .unit,
            equilibriumConstant: 1,
            beakerCols: 10,
            beakerRows: 10,
            maxBeakerRows: 10,
            dynamicGridCols: 10,
            dynamicGridRows: 10,
            startTime: 0,
            equilibriumTime: 10
        )
        model.increment(molecule: .B, count: 30)

        var getBCoords: [GridCoordinate] {
            model.components.equilibriumGrid.reactantB.coordinates
        }

        let bCoordsPreAIncrement = getBCoords

        model.increment(molecule: .A, count: 30)
        XCTAssertEqual(getBCoords, bCoordsPreAIncrement)
    }

    private func gridCountFor(_ concentration: CGFloat) -> Int {
        (concentration * 100).roundedInt()
    }
}
