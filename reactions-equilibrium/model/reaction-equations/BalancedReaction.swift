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

    init(
        coefficients: BalancedReactionCoefficients,
        a0: CGFloat,
        b0: CGFloat,
        convergenceTime: CGFloat
    ) {

        let forwardReaction = BalancedEquationBuilder.getEquations(
            a: MoleculeTerms(initC: a0, coeff: coefficients.reactantA, increases: false),
            b: MoleculeTerms(initC: b0, coeff: coefficients.reactantB, increases: false),
            c: MoleculeTerms(initC: 0, coeff: coefficients.productC, increases: true),
            d: MoleculeTerms(initC: 0, coeff: coefficients.productD, increases: true),
            startTime: 0,
            convergenceTime: convergenceTime
        )

        self.coefficients = coefficients
        self.convergenceTime = convergenceTime
        self.a0 = a0
        self.b0 = b0

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
        let reverseReaction = BalancedEquationBuilder.getEquations(
            a: MoleculeTerms(initC: initA, coeff: forwardReaction.coefficients.reactantA, increases: true),
            b: MoleculeTerms(initC: initB, coeff: forwardReaction.coefficients.reactantB, increases: true),
            c: MoleculeTerms(initC: reverseInput.c0, coeff: forwardReaction.coefficients.productC, increases: false),
            d: MoleculeTerms(initC: reverseInput.d0, coeff: forwardReaction.coefficients.productD, increases: false),
            startTime: reverseInput.startTime,
            convergenceTime: reverseInput.convergenceTime
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
        self.coefficients = forwardReaction.coefficients

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

    func a0ForConvergence(of finalConcentration: CGFloat) -> CGFloat {
        reactant0ForConvergence(of: finalConcentration, coeff: coefficients.reactantA, otherReactant0: b0)
    }

    func b0ForConvergence(of finalConcentration: CGFloat) -> CGFloat {
        reactant0ForConvergence(of: finalConcentration, coeff: coefficients.reactantB, otherReactant0: a0)
    }

    private func reactant0ForConvergence(
        of finalConcentration: CGFloat,
        coeff: Int,
        otherReactant0: CGFloat
    ) -> CGFloat {
        let coeffSum = coefficients.sum
        let numer = (CGFloat(coeffSum) * finalConcentration) + (CGFloat(coeff) * otherReactant0)
        let denom = coeffSum - coeff
        assert(denom != 0)
        return numer / CGFloat(denom)
    }
}


private struct BalancedEquationBuilder {

    static func getEquations(
        a: MoleculeTerms,
        b: MoleculeTerms,
        c: MoleculeTerms,
        d: MoleculeTerms,
        startTime: CGFloat,
        convergenceTime: CGFloat
    ) -> SetOfEquations {
        let unitChange = getUnitChange(a: a, b: b, c: c, d: d)
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

    static func getUnitChange(
        a: MoleculeTerms,
        b: MoleculeTerms,
        c: MoleculeTerms,
        d: MoleculeTerms
    ) -> CGFloat {
        let numer = a.initC + b.initC - c.initC - d.initC
        let denom = c.denomTerm + d.denomTerm - a.denomTerm - b.denomTerm
        assert(denom != 0)
        return numer / denom
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
