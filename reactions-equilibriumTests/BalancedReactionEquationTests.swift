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
            convergenceTime: 10
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

    func testB0ForGivenConvergence() {
        let coeffs = makeCoeffs(A: 1, B: 1, C: 1, D: 1)
        let equation = BalancedReactionEquations(coefficients: coeffs, a0: 0.5, b0: 0, convergenceTime: 10)
        XCTAssertEqual(equation.b0ForConvergence(of: 0.25), 0.5)
    }

    func testA0ForGivenConvergence() {
        let coeffs = makeCoeffs(A: 2, B: 1, C: 1, D: 1)
        let equation = BalancedReactionEquations(coefficients: coeffs, a0: 0.5, b0: 0.5, convergenceTime: 10)
        XCTAssertEqual(equation.a0ForConvergence(of: 0.25), 0.75)
        testCorrectA0ForConvergence(of: 0.25, equation: equation)
    }

    func testAFewDifferentA0InputsForGivenConvergence() {
        typealias Input = (A: Int, B: Int, C: Int, D: Int, b0: CGFloat, target: CGFloat)
        func doTest(
            input: Input
        ) {
            let coeffs = makeCoeffs(A: input.A, B: input.B, C: input.C, D: input.D)
            let equation = BalancedReactionEquations(coefficients: coeffs, a0: 0, b0: input.b0, convergenceTime: 10)
            testCorrectA0ForConvergence(of: input.target, equation: equation)
        }

        let cases: [Input] = [
            (A: 1, B: 1, C: 3, D: 4, b0: 1, target: 0.4),
            (A: 2, B: 2, C: 3, D: 4, b0: 0.75, target: 0.3),
            (A: 3, B: 3, C: 2, D: 4, b0: 0.5, target: 0.2),
            (A: 4, B: 4, C: 2, D: 4, b0: 0.25, target: 0.1),
        ]

        cases.forEach { c in
            doTest(input: c)
        }
    }

    private func testCorrectA0ForConvergence(
        of convergence: CGFloat,
        equation: BalancedReactionEquations
    ) {
        let t = equation.convergenceTime
        XCTAssertNotEqual(equation.reactantA.getY(at: t), convergence, accuracy: 0.000001, "Initial convergence should be different than target convergence")
        let resultA0 = equation.a0ForConvergence(of: convergence)
        let newEquation = equation.withA0(resultA0)
        XCTAssertEqual(newEquation.reactantA.getY(at: t), convergence, accuracy: 0.000001)
    }

    private func makeCoeffs(A: Int, B: Int, C: Int, D: Int) -> BalancedReactionCoefficients {
        BalancedReactionCoefficients(reactantA: A, reactantB: B, productC: C, productD: D)
    }

}

private extension BalancedReactionEquations {
    func withA0(_ newValue: CGFloat) -> BalancedReactionEquations {
        BalancedReactionEquations(
            coefficients: coefficients,
            a0: newValue,
            b0: b0,
            convergenceTime: convergenceTime
        )
    }
}
