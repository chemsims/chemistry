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
            a0: 0.4,
            b0: 0.5,
            finalTime: 10
        )

        XCTAssertEqual(equations.reactantA.getY(at: 0), 0.4)
        XCTAssertEqual(equations.reactantA.getY(at: 10), 0.2)

        XCTAssertEqual(equations.reactantB.getY(at: 0), 0.5)
        XCTAssertEqual(equations.reactantB.getY(at: 10), 0.3)

        XCTAssertEqual(equations.productC.getY(at: 0), 0)
        XCTAssertEqual(equations.productC.getY(at: 10), 0.1)

        XCTAssertEqual(equations.productD.getY(at: 0), 0)
        XCTAssertEqual(equations.productD.getY(at: 10), 0.4)
    }

    func testReactionIsValid() {
        let coeffs = makeCoeffs(A: 1, B: 1, C: 1, D: 1)
        let equation = BalancedReactionEquations(coefficients: coeffs, a0: 0.5, b0: 0.5, finalTime: 10)
        XCTAssert(equation.isValid)
        XCTAssertNil(equation.reactantToAddForValidReaction)
    }

    func testReactionIsInvalid() {
        let coeffs = makeCoeffs(A: 1, B: 1, C: 1, D: 1)
        let equation = BalancedReactionEquations(coefficients: coeffs, a0: 0.5, b0: 0, finalTime: 10)
        XCTAssertFalse(equation.isValid)
    }

    func testBIsNeededToMakeEquationValid() {
        let coeffs = makeCoeffs(A: 1, B: 1, C: 1, D: 1)
        let equation = BalancedReactionEquations(coefficients: coeffs, a0: 0.5, b0: 0, finalTime: 10)
        XCTAssertEqual(equation.reactantToAddForValidReaction, .B)
    }

    func testAIsNeededToMakeEquationValid() {
        let coeffs = makeCoeffs(A: 1, B: 1, C: 1, D: 1)
        let equation = BalancedReactionEquations(coefficients: coeffs, a0: 0, b0: 0.5, finalTime: 10)
        XCTAssertEqual(equation.reactantToAddForValidReaction, .A)
    }

    private func makeCoeffs(A: Int, B: Int, C: Int, D: Int) -> BalancedReactionCoefficients {
        BalancedReactionCoefficients(reactantA: A, reactantB: B, productC: C, productD: D)
    }

}
