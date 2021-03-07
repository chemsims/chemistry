//
// Reactions App
//

import XCTest
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

        XCTAssertEqual(aGrid.fractionToDraw.getY(at: 0), 1)
        XCTAssertEqual(aGrid.fractionToDraw.getY(at: 5), reaction.reactantA.getY(at: 5) / 0.5)
        XCTAssertEqual(aGrid.fractionToDraw.getY(at: 10), 0.5)

        XCTAssertEqual(bGrid.fractionToDraw.getY(at: 0), 1)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: 5), reaction.reactantB.getY(at: 5) / 0.5)
        XCTAssertEqual(bGrid.fractionToDraw.getY(at: 10), 0.5)

        XCTAssertEqual(cGrid.fractionToDraw.getY(at: 0), 0)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: 5), reaction.productC.getY(at: 5) / 0.25)
        XCTAssertEqual(cGrid.fractionToDraw.getY(at: 10), 1)

        XCTAssertEqual(dGrid.fractionToDraw.getY(at: 0), 0)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: 5), reaction.productD.getY(at: 5) / 0.25)
        XCTAssertEqual(dGrid.fractionToDraw.getY(at: 10), 1)
    }

    private func gridCountFor(_ concentration: CGFloat) -> Int {
        (concentration * CGFloat(EquilibriumGridSettings.grid.count)).roundedInt()
    }
}
