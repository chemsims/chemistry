//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import reactions_equilibrium

class GridMoleculesTests: XCTestCase {

    func testForwardGridMolecules() {
        var model = ForwardGridMolecules()
        var reaction = BalancedReactionEquations(coefficients: .unit, equilibriumConstant: 1, a0: 0, b0: 0, convergenceTime: 10)

        func setConcentration(of reactant: AqueousMoleculeReactant, _ newValue: CGFloat) {
            reaction = reactant == .A ? reaction.withA0(newValue) : reaction.withB0(newValue)
            model.setConcentration(of: reactant, concentration: newValue)
        }

        var aGrid: FractionedCoordinates { model.aGrid(reaction: reaction) }
        var bGrid: FractionedCoordinates { model.bGrid(reaction: reaction) }
        var cGrid: FractionedCoordinates { model.cGrid(reaction: reaction) }
        var dGrid: FractionedCoordinates { model.dGrid(reaction: reaction) }

        XCTAssertEqual(aGrid.coordinates, [])
        XCTAssertEqual(bGrid.coordinates, [])
        XCTAssertEqual(cGrid.coordinates, [])
        XCTAssertEqual(dGrid.coordinates, [])

        setConcentration(of: .A, 0.5)
        setConcentration(of: .B, 0.5)
        XCTAssertEqual(aGrid.coordinates.count, gridCountFor(0.5))
        XCTAssertEqual(bGrid.coordinates.count, gridCountFor(0.5))
        XCTAssertEqual(cGrid.coordinates.count, gridCountFor(0.25))
        XCTAssertEqual(dGrid.coordinates.count, gridCountFor(0.25))

        func expectedFraction(_ c: CGFloat, _ initC: CGFloat) -> CGFloat {
            CGFloat(gridCountFor(c)) / CGFloat(gridCountFor(initC))
        }

        XCTAssertEqual(aGrid.fractionToDraw.getY(at: 0), 1)
        XCTAssertEqual(aGrid.fractionToDraw.getY(at: 3), expectedFraction(reaction.reactantA.getY(at: 3), 0.5), accuracy: 0.00001)
        XCTAssertEqual(aGrid.fractionToDraw.getY(at: 5), expectedFraction(reaction.reactantA.getY(at: 5), 0.5), accuracy: 0.00001)
        XCTAssertEqual(aGrid.fractionToDraw.getY(at: 10), expectedFraction(reaction.reactantA.getY(at: 10), 0.5), accuracy: 0.00001)

        XCTAssertEqual(bGrid.fractionToDraw.getY(at: 0), 1)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: 3), expectedFraction(reaction.reactantB.getY(at: 3), 0.5), accuracy: 0.00001)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: 5), expectedFraction(reaction.reactantB.getY(at: 5), 0.5), accuracy: 0.00001)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: 10), expectedFraction(reaction.reactantB.getY(at: 10), 0.5), accuracy: 0.00001)

        XCTAssertEqual(cGrid.fractionToDraw.getY(at: 0), 0)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: 3), expectedFraction(reaction.productC.getY(at: 3), 0.25))
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: 5), expectedFraction(reaction.productC.getY(at: 5), 0.25))
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: 10), 1)

        XCTAssertEqual(dGrid.fractionToDraw.getY(at: 0), 0)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: 3), expectedFraction(reaction.productD.getY(at: 3), 0.25))
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: 5), expectedFraction(reaction.productD.getY(at: 5), 0.25))
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: 10), 1)
    }

    func testReverseGridMolecules() {
        let tAddProd = AqueousReactionSettings.timeToAddProduct
        let tEnd = AqueousReactionSettings.timeForReverseConvergence
        let forwardReaction = BalancedReactionEquations(coefficients: .unit, equilibriumConstant: 1, a0: 0.5, b0: 0.5, convergenceTime: 10)
        var forwardGrid = ForwardGridMolecules()
        forwardGrid.setConcentration(of: .A, concentration: 0.5)
        forwardGrid.setConcentration(of: .B, concentration: 0.5)

        func newReverseReaction(c0: CGFloat, d0: CGFloat) -> BalancedReactionEquations {
            BalancedReactionEquations(
                forwardReaction: forwardReaction,
                reverseInput: ReverseReactionInput(
                    c0: c0,
                    d0: d0,
                    startTime: tAddProd,
                    convergenceTime: tEnd
                )
            )
        }

        var reverseReaction = newReverseReaction(c0: 0.25, d0: 0.25)
        var reverseGrid = ReverseGridMolecules(forwardGrid: forwardGrid, forwardReaction: forwardReaction)

        func setConcentration(of product: AqueousMoleculeProduct, _ newValue: CGFloat) {
            reverseGrid.setConcentration(of: product, concentration: newValue)
            reverseReaction = newReverseReaction(c0: product == .C ? newValue : 0.25, d0: product == .D ? newValue : 0.25)
        }

        var aGrid: FractionedCoordinates { reverseGrid.aGrid(reaction: reverseReaction) }
        var bGrid: FractionedCoordinates { reverseGrid.bGrid(reaction: reverseReaction) }
        var cGrid: FractionedCoordinates { reverseGrid.cGrid(reaction: reverseReaction) }
        var dGrid: FractionedCoordinates { reverseGrid.dGrid(reaction: reverseReaction) }


        func testStartOfReactionBeforeProductIsAdded(reverseCoords: FractionedCoordinates, expectedForwardCoords: [GridCoordinate]) {
            XCTAssertEqual(reverseCoords.coordinates, expectedForwardCoords)
            XCTAssertEqual(reverseCoords.fractionToDraw.getY(at: tAddProd), 1, accuracy: 0.0001)
            XCTAssertEqual(reverseCoords.fractionToDraw.getY(at: tEnd), 1, accuracy: 0.0001)
        }

        let expectedInitA = Array(forwardGrid.aGrid(reaction: forwardReaction).coordinates.prefix(gridCountFor(0.25)))
        let expectedInitB = Array(forwardGrid.bGrid(reaction: forwardReaction).coordinates.prefix(gridCountFor(0.25)))

        testStartOfReactionBeforeProductIsAdded(reverseCoords: aGrid, expectedForwardCoords: expectedInitA)
        testStartOfReactionBeforeProductIsAdded(reverseCoords: bGrid, expectedForwardCoords: expectedInitB)
        testStartOfReactionBeforeProductIsAdded(reverseCoords: cGrid, expectedForwardCoords: forwardGrid.cGrid(reaction: forwardReaction).coordinates)
        testStartOfReactionBeforeProductIsAdded(reverseCoords: dGrid, expectedForwardCoords: forwardGrid.dGrid(reaction: forwardReaction).coordinates)

        reverseGrid.setConcentration(of: .C, concentration: 0.5)
        reverseGrid.setConcentration(of: .D, concentration: 0.5)
        reverseReaction = newReverseReaction(c0: 0.5, d0: 0.5)

        // unitChange is 0.125
        XCTAssertEqual(aGrid.coordinates.count, gridCountFor(0.375))
        XCTAssertEqual(bGrid.coordinates.count, gridCountFor(0.375))
        XCTAssertEqual(cGrid.coordinates.count, gridCountFor(0.5))
        XCTAssertEqual(dGrid.coordinates.count, gridCountFor(0.5))

        XCTAssertEqual(aGrid.fractionToDraw.getY(at: tAddProd), CGFloat(gridCountFor(0.25)) / CGFloat(gridCountFor(0.375)), accuracy: 0.0001)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: tAddProd), CGFloat(gridCountFor(0.25)) / CGFloat(gridCountFor(0.375)), accuracy: 0.0001)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: tAddProd), 1, accuracy: 0.0001)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: tAddProd), 1, accuracy: 0.0001)

        XCTAssertEqual(aGrid.fractionToDraw.getY(at: tEnd), 1)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: tEnd), 1)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: tEnd), CGFloat(gridCountFor(0.375)) / CGFloat(gridCountFor(0.5)), accuracy: 0.0001)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: tEnd), CGFloat(gridCountFor(0.375)) / CGFloat(gridCountFor(0.5)), accuracy: 0.0001)

        let dt = tEnd - tAddProd
        let tMid = tAddProd + (dt / 3)
        func expectedFraction(_ underlying: Equation, _ initC: CGFloat) -> CGFloat {
            CGFloat(gridCountFor(underlying.getY(at: tMid))) / CGFloat(gridCountFor(initC))
        }

        XCTAssertEqual(aGrid.fractionToDraw.getY(at: tMid), expectedFraction(reverseReaction.reactantA, 0.375), accuracy: 0.0001)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: tMid), expectedFraction(reverseReaction.productC, 0.5), accuracy: 0.0001)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: tMid), expectedFraction(reverseReaction.productD, 0.5), accuracy: 0.0001)
    }

    private func gridCountFor(_ concentration: CGFloat) -> Int {
        (concentration * CGFloat(EquilibriumGridSettings.grid.count)).roundedInt()
    }
}
