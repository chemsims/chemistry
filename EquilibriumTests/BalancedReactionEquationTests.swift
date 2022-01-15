//
// Reactions App
//

import XCTest
@testable import Equilibrium

class BalancedReactionEquationTests: XCTestCase {

    func testBalancedReactionExample() {
        let coeffs = makeCoeffs(A: 2, B: 2, C: 1, D: 4)
        let model = BalancedReactionEquation(
            coefficients: coeffs,
            equilibriumConstant: 1,
            initialConcentrations: MoleculeValue(
                reactantA: 0.4,
                reactantB: 0.5,
                productC: 0,
                productD: 0
            ), startTime: 0,
            equilibriumTime: 10,
            previous: nil
        )
        let equations = model.concentration

        let quotient = ReactionQuotientEquation(equations: model)
        XCTAssertEqual(quotient.getValue(at: 10), 1, accuracy: 0.001)

        let unitChange: CGFloat = 0.10411
        XCTAssertEqual(equations.reactantA.getValue(at: 0), 0.4)
        XCTAssertEqual(equations.reactantA.getValue(at: 10), 0.4 - (2 * unitChange), accuracy: tolerance)

        XCTAssertEqual(equations.reactantB.getValue(at: 0), 0.5)
        XCTAssertEqual(equations.reactantB.getValue(at: 10), 0.5 - (2 * unitChange), accuracy: tolerance)

        XCTAssertEqual(equations.productC.getValue(at: 0), 0)
        XCTAssertEqual(equations.productC.getValue(at: 10), unitChange, accuracy: tolerance)

        XCTAssertEqual(equations.productD.getValue(at: 0), 0)
        XCTAssertEqual(equations.productD.getValue(at: 10), 4 * unitChange, accuracy: tolerance)
    }

    func testBalancedReactionConvergenceForAPressureReaction() {
        let k: CGFloat = 0.01
        let equation = BalancedReactionEquation(
            coefficients: BalancedReactionCoefficients(reactantA: 1, reactantB: 2, productC: 3, productD: 4),
            equilibriumConstant: k,
            initialConcentrations: MoleculeValue(reactantA: 0.3, reactantB: 0.3, productC: 0, productD: 0),
            startTime: 0,
            equilibriumTime: 10,
            previous: nil,
            usePressureValues: true
        )

        let expectedPressureQuotient = GaseousReactionSettings.pressureConstantFromConcentrationConstant(k, coefficients: equation.coefficients)
        let pressureQuotient = ReactionQuotientEquation(coefficients: equation.coefficients, equations: equation.pressure)

        XCTAssertEqual(pressureQuotient.getValue(at: 10), expectedPressureQuotient, accuracy: 0.001)
    }

    private func makeCoeffs(A: Int, B: Int, C: Int, D: Int) -> BalancedReactionCoefficients {
        BalancedReactionCoefficients(reactantA: A, reactantB: B, productC: C, productD: D)
    }

    private let tolerance: CGFloat = 0.0001

}

