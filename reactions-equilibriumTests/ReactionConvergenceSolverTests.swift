//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium

class ReactionConvergenceSolverTests: XCTestCase {

    func testForwardReactionWithUnitCoefficientsAndEqualReactants() {
        let unitChange = ReactionConvergenceSolver.findUnitChangeFor(
            equilibriumConstant: 1,
            coeffs: .unit,
            initialConcentrations: BalancedReactionInitialConcentrations(
                reactantA: 0.5, reactantB: 0.5, productC: 0, productD: 0
            ),
            isForward: true
        )
        XCTAssertEqual(unitChange, 0.25, accuracy: tolerance)
    }

    func testReverseReactionWithUnitCoefficientsAndEqualProducts() {
        let unitChange = ReactionConvergenceSolver.findUnitChangeFor(
            equilibriumConstant: 1,
            coeffs: .unit,
            initialConcentrations: BalancedReactionInitialConcentrations(
                reactantA: 0.3, reactantB: 0.3, productC: 0.6, productD: 0.6
            ),
            isForward: false
        )
        XCTAssertEqual(unitChange, 0.15, accuracy: tolerance)
    }

    func testForwardReactionWithUnitCoefficientsAndNonEqualReactants() {
        let unitChange = ReactionConvergenceSolver.findUnitChangeFor(
            equilibriumConstant: 1,
            coeffs: .unit,
            initialConcentrations: BalancedReactionInitialConcentrations(
                reactantA: 0.3, reactantB: 0.15, productC: 0, productD: 0
            ),
            isForward: true
        )
        XCTAssertEqual(unitChange, 0.1, accuracy: tolerance)
    }

    func testReverseReactionWithUnitCoefficientsAndNonEqualProductsAndReactants() {
        let unitChange = ReactionConvergenceSolver.findUnitChangeFor(
            equilibriumConstant: 1,
            coeffs: .unit,
            initialConcentrations: BalancedReactionInitialConcentrations(
                reactantA: 0.1, reactantB: 0.2, productC: 0.4, productD: 0.6
            ),
            isForward: false
        )
        XCTAssertEqual(unitChange, 0.1692, accuracy: tolerance)
    }

    private let tolerance: CGFloat = 0.0001
}
