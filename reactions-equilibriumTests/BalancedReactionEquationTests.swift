//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium

class BalancedReactionEquationTests: XCTestCase {

    func testBalancedReactionExample() {
        let coeffs = makeCoeffs(A: 2, B: 2, C: 1, D: 4)
        let equations = BalancedReactionEquations(
            coefficients: coeffs,
            equilibriumConstant: 1,
            a0: 0.4,
            b0: 0.5,
            convergenceTime: 10
        )
        let quotient = ReactionQuotientEquation(equations: equations)
        XCTAssertEqual(quotient.getY(at: 10), 1, accuracy: 0.001)

        let unitChange: CGFloat = 0.10411
        XCTAssertEqual(equations.reactantA.getY(at: 0), 0.4)
        XCTAssertEqual(equations.reactantA.getY(at: 10), 0.4 - (2 * unitChange), accuracy: tolerance)

        XCTAssertEqual(equations.reactantB.getY(at: 0), 0.5)
        XCTAssertEqual(equations.reactantB.getY(at: 10), 0.5 - (2 * unitChange), accuracy: tolerance)

        XCTAssertEqual(equations.productC.getY(at: 0), 0)
        XCTAssertEqual(equations.productC.getY(at: 10), unitChange, accuracy: tolerance)

        XCTAssertEqual(equations.productD.getY(at: 0), 0)
        XCTAssertEqual(equations.productD.getY(at: 10), 4 * unitChange, accuracy: tolerance)
    }

    private func makeCoeffs(A: Int, B: Int, C: Int, D: Int) -> BalancedReactionCoefficients {
        BalancedReactionCoefficients(reactantA: A, reactantB: B, productC: C, productD: D)
    }

    private let tolerance: CGFloat = 0.0001

}

