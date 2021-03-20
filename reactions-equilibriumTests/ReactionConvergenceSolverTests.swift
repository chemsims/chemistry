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
        XCTAssertEqual(unitChange!, 0.25, accuracy: tolerance)
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
        XCTAssertEqual(unitChange!, 0.15, accuracy: tolerance)
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
        XCTAssertEqual(unitChange!, 0.1, accuracy: tolerance)
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
        XCTAssertEqual(unitChange!, 0.1692, accuracy: tolerance)
    }

    func testForwardReactionConvergenceWithMultipleNonUnitCoefficients() {
        let equation = BalancedReactionEquation(
            coefficients: BalancedReactionCoefficients(reactantA: 3, reactantB: 2, productC: 1, productD: 2),
            equilibriumConstant: 0.1,
            initialConcentrations: MoleculeValue(
                reactantA: 0.15,
                reactantB: 0.2,
                productC: 0,
                productD: 0
            ),
            startTime: 0,
            equilibriumTime: 10,
            previous: nil
        )
        let quotient = ReactionQuotientEquation(equations: equation)
        XCTAssertEqual(quotient.getY(at: 10), 0.1, accuracy: ReactionConvergenceSolver.tolerance)
    }

    func testInputRangeForReactionA() {
        runInputTestRangeForReactionType(reaction: .A)
    }

    func testInputRangeForReactionB() {
        runInputTestRangeForReactionType(reaction: .B)
    }

    func testInputRangeForReactionC() {
        runInputTestRangeForReactionType(reaction: .C)
    }

    private func runInputTestRangeForReactionType(
        reaction: AqueousReactionType
    ) {
        let minReactant = AqueousReactionSettings.ConcentrationInput.minInitial
        let maxReactant = AqueousReactionSettings.ConcentrationInput.maxInitial
        let dc: CGFloat = 0.015

        let tEnd: CGFloat = 10
        let tProdAdd: CGFloat = 11
        let tFinal: CGFloat = 20
        let reactantRange = stride(from: minReactant, through: maxReactant, by: dc)
        
        reactantRange.forEach { a in
            reactantRange.forEach { b in
                let debug = "A: \(a), B: \(b)"
                let equation = BalancedReactionEquation(
                    coefficients: reaction.coefficients,
                    equilibriumConstant: reaction.equilibriumConstant,
                    initialConcentrations: MoleculeValue(
                        reactantA: a,
                        reactantB: b,
                        productC: 0,
                        productD: 0
                    ),
                    startTime: 0,
                    equilibriumTime: tEnd,
                    previous: nil
                )
                let quotient = ReactionQuotientEquation(equations: equation)
                XCTAssertEqual(
                    quotient.getY(at: tEnd),
                    reaction.equilibriumConstant,
                    accuracy: 0.001,
                    debug
                )

                XCTAssertGreaterThan(equation.concentration.reactantA.getY(at: tEnd), 0, debug)
                XCTAssertGreaterThan(equation.concentration.reactantB.getY(at: tEnd), 0, debug)
                XCTAssertGreaterThan(equation.concentration.productC.getY(at: tEnd), 0, debug)
                XCTAssertGreaterThan(equation.concentration.productD.getY(at: tEnd), 0, debug)

                // reverse
                let minProduct: CGFloat = 0
                let maxProduct = AqueousReactionSettings.ConcentrationInput.maxInitial
                let productRange = stride(from: minProduct, through: maxProduct, by: dc)
                productRange.forEach { c in
                    productRange.forEach { d in
                        let reverseEquation = BalancedReactionEquation(
                            coefficients: equation.coefficients,
                            equilibriumConstant: equation.equilibriumConstant,
                            initialConcentrations: MoleculeValue(
                                reactantA: equation.equilibriumConcentrations.reactantA,
                                reactantB: equation.equilibriumConcentrations.reactantB,
                                productC: equation.equilibriumConcentrations.productC + c,
                                productD: equation.equilibriumConcentrations.productD + d
                            ),
                            startTime: tProdAdd,
                            equilibriumTime: tFinal,
                            previous: equation
                        )
                        XCTAssertGreaterThan(reverseEquation.concentration.reactantA.getY(at: tFinal), 0)
                        XCTAssertGreaterThan(reverseEquation.concentration.reactantB.getY(at: tFinal), 0)
                        XCTAssertGreaterThan(reverseEquation.concentration.productC.getY(at: tFinal), 0)
                        XCTAssertGreaterThan(reverseEquation.concentration.productD.getY(at: tFinal), 0)
                        let reverseQuotient = ReactionQuotientEquation(equations: reverseEquation)
                        XCTAssertEqual(reverseQuotient.getY(at: tEnd), reaction.equilibriumConstant, accuracy: 0.001)
                    }
                }
            }
        }
    }

    private let tolerance: CGFloat = ReactionConvergenceSolver.tolerance
}
