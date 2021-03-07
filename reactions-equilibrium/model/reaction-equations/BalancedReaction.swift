//
// Reactions App
//

import Foundation
import ReactionsCore
import CoreGraphics

struct BalancedReactionCoefficients {
    let reactantA: Int
    let reactantB: Int
    let productC: Int
    let productD: Int
}

struct BalancedReactionInitialConcentrations {
    let reactantA: CGFloat
    let reactantB: CGFloat
    let productC: CGFloat
    let productD: CGFloat
}

private extension BalancedReactionCoefficients {
    var sum: Int {
        reactantA + reactantB + productC + productD
    }
}

struct BalancedReactionEquations {

    let reactantA: Equation
    let reactantB: Equation
    let productC: Equation
    let productD: Equation

    let coefficients: BalancedReactionCoefficients
    let convergenceTime: CGFloat

    let a0: CGFloat
    let b0: CGFloat

    let direction: ReactionDirection

    let equilibriumConstant: CGFloat

    private let hasNonNilUnitChange: Bool

    init(
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        a0: CGFloat,
        b0: CGFloat,
        convergenceTime: CGFloat
    ) {
        let unitChange = ReactionConvergenceSolver.findUnitChangeFor(
            equilibriumConstant: equilibriumConstant,
            coeffs: coefficients,
            initialConcentrations: BalancedReactionInitialConcentrations(
                reactantA: a0, reactantB: b0, productC: 0, productD: 0
            ),
            isForward: true
        )
        let forwardReaction = BalancedEquationBuilder.getEquations(
            a: MoleculeTerms(initC: a0, coeff: coefficients.reactantA, increases: false),
            b: MoleculeTerms(initC: b0, coeff: coefficients.reactantB, increases: false),
            c: MoleculeTerms(initC: 0, coeff: coefficients.productC, increases: true),
            d: MoleculeTerms(initC: 0, coeff: coefficients.productD, increases: true),
            startTime: 0,
            convergenceTime: convergenceTime,
            unitChange: unitChange ?? 0
        )

        self.coefficients = coefficients
        self.convergenceTime = convergenceTime
        self.a0 = a0
        self.b0 = b0
        self.equilibriumConstant = equilibriumConstant
        self.hasNonNilUnitChange = unitChange != nil
        self.direction = .forward

        self.reactantA = forwardReaction.reactantA
        self.reactantB = forwardReaction.reactantB
        self.productC = forwardReaction.productC
        self.productD = forwardReaction.productD
    }

    init(
        forwardReaction: BalancedReactionEquations,
        reverseInput: ReverseReactionInput
    ) {
        let initA = forwardReaction.reactantA.getY(at: forwardReaction.convergenceTime)
        let initB = forwardReaction.reactantB.getY(at: forwardReaction.convergenceTime)

        let unitChange = ReactionConvergenceSolver.findUnitChangeFor(
            equilibriumConstant: forwardReaction.equilibriumConstant,
            coeffs: forwardReaction.coefficients,
            initialConcentrations: BalancedReactionInitialConcentrations(
                reactantA: initA, reactantB: initB, productC: reverseInput.c0, productD: reverseInput.d0
            ),
            isForward: false
        )

        let reverseReaction = BalancedEquationBuilder.getEquations(
            a: MoleculeTerms(initC: initA, coeff: forwardReaction.coefficients.reactantA, increases: true),
            b: MoleculeTerms(initC: initB, coeff: forwardReaction.coefficients.reactantB, increases: true),
            c: MoleculeTerms(initC: reverseInput.c0, coeff: forwardReaction.coefficients.productC, increases: false),
            d: MoleculeTerms(initC: reverseInput.d0, coeff: forwardReaction.coefficients.productD, increases: false),
            startTime: reverseInput.startTime,
            convergenceTime: reverseInput.convergenceTime,
            unitChange: unitChange ?? 0
        )

        func getEquation(lhs: Equation, rhs: Equation) -> Equation {
            SwitchingEquation(
                thresholdX: reverseInput.startTime,
                underlyingLeft: lhs,
                underlyingRight: rhs
            )
        }

        self.reactantA = getEquation(lhs: forwardReaction.reactantA, rhs: reverseReaction.reactantA)
        self.reactantB = getEquation(lhs: forwardReaction.reactantB, rhs: reverseReaction.reactantB)
        self.productC = getEquation(lhs: forwardReaction.productC, rhs: reverseReaction.productC)
        self.productD = getEquation(lhs: forwardReaction.productD, rhs: reverseReaction.productD)

        self.a0 = forwardReaction.a0
        self.b0 = forwardReaction.b0
        self.equilibriumConstant = forwardReaction.equilibriumConstant
        self.coefficients = forwardReaction.coefficients
        self.hasNonNilUnitChange = unitChange != nil
        self.direction = .reverse

        self.convergenceTime = reverseInput.convergenceTime
    }
}

extension BalancedReactionEquations {
    var equationArray: [Equation] {
        [reactantA, reactantB, productC, productD]
    }
}

extension BalancedReactionEquations {

    func reactantToAddForMinConvergence(convergence: CGFloat) -> AqueousMoleculeReactant? {
        if reactantA.getY(at: convergenceTime) < convergence {
            return .A
        } else if reactantB.getY(at: convergenceTime) < convergence {
            return .B
        }
        return nil
    }
}


private struct BalancedEquationBuilder {

    static func getEquations(
        a: MoleculeTerms,
        b: MoleculeTerms,
        c: MoleculeTerms,
        d: MoleculeTerms,
        startTime: CGFloat,
        convergenceTime: CGFloat,
        unitChange: CGFloat
    ) -> SetOfEquations {
        
        func getEquation(for terms: MoleculeTerms) -> Equation {
            elementEquation(
                terms: terms,
                unitChange: unitChange,
                startTime: startTime,
                convergenceTime: convergenceTime
            )
        }

        return SetOfEquations(
            reactantA: getEquation(for: a),
            reactantB: getEquation(for: b),
            productC: getEquation(for: c),
            productD: getEquation(for: d)
        )
    }

    private static func elementEquation(
        terms: MoleculeTerms,
        unitChange: CGFloat,
        startTime: CGFloat,
        convergenceTime: CGFloat
    ) -> Equation {
        let unitChangeDirection = terms.increases ? unitChange : -unitChange
        let finalConcentration = terms.initC + (CGFloat(terms.coeff) * unitChangeDirection)
        return EquilibriumReactionEquation(
            t1: startTime,
            c1: terms.initC,
            t2: convergenceTime,
            c2: finalConcentration
        )
    }
}

private struct MoleculeTerms {
    let initC: CGFloat
    let coeff: Int
    let increases: Bool

    var denomTerm: CGFloat {
        CGFloat(increases ? coeff : -coeff)
    }
}

struct ReverseReactionInput {
    let c0: CGFloat
    let d0: CGFloat
    let startTime: CGFloat
    let convergenceTime: CGFloat
}

private struct SetOfEquations {
    let reactantA: Equation
    let reactantB: Equation
    let productC: Equation
    let productD: Equation
}
