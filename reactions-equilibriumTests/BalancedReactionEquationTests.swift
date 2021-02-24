//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium

class BalancedReactionEquationTests: XCTestCase {

    func testBalancedReactionExample() {
        let coeffs = BalancedReactionCoefficients(
            reactantACoefficient: 2,
            reactantBCoefficient: 2,
            productCCoefficient: 1,
            productDCoefficient: 4
        )
        let equations = BalancedReactionEquations(
            coefficients: coeffs,
            a0: 0.4,
            b0: 0.5,
            finalTime: 10
        )

        // Reactant A
        XCTAssertEqual(equations.reactantA.getY(at: 0), 0.4)
        XCTAssertEqual(equations.reactantA.getY(at: 10), 0.2)

        // Reactant B
        XCTAssertEqual(equations.reactantB.getY(at: 0), 0.5)
        XCTAssertEqual(equations.reactantB.getY(at: 10), 0.3)

        // Product C
        XCTAssertEqual(equations.productC.getY(at: 0), 0)
        XCTAssertEqual(equations.productC.getY(at: 10), 0.1)

        // Product D
        XCTAssertEqual(equations.productD.getY(at: 0), 0)
        XCTAssertEqual(equations.productD.getY(at: 10), 0.4)
    }

}
