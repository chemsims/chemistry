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

    init(
        coefficients: BalancedReactionCoefficients,
        a0: CGFloat,
        b0: CGFloat,
        finalTime: CGFloat
    ) {
        self.coefficients = coefficients
        self.convergenceTime = finalTime
        
        let unitChange = (a0 + b0) / CGFloat(coefficients.sum)

        func reactantEquation(initC: CGFloat, coeff: Int) -> Equation {
            BalancedReactionEquations.reactantEquation(initC, coefficient: coeff, unitChange: unitChange, finalTime: finalTime)
        }

        func productEquation(coeff: Int) -> Equation {
            BalancedReactionEquations.productEquation(0, coefficient: coeff, unitChange: unitChange, finalTime: finalTime)
        }

        self.reactantA = reactantEquation(initC: a0, coeff: coefficients.reactantA)
        self.reactantB = reactantEquation(initC: b0, coeff: coefficients.reactantB)
        self.productC = productEquation(coeff: coefficients.productC)
        self.productD = productEquation(coeff: coefficients.productD)
    }

    private static func reactantEquation(
        _ initialConcentration: CGFloat,
        coefficient: Int,
        unitChange: CGFloat,
        finalTime: CGFloat
    ) -> Equation {
        elementEquation(
            initialConcentration,
            coefficient: coefficient,
            increases: false,
            unitChange: unitChange,
            finalTime: finalTime
        )
    }

    private static func productEquation(
        _ initialConcentration: CGFloat,
        coefficient: Int,
        unitChange: CGFloat,
        finalTime: CGFloat
    ) -> Equation {
        elementEquation(
            initialConcentration,
            coefficient: coefficient,
            increases: true,
            unitChange: unitChange,
            finalTime: finalTime
        )
    }

    private static func elementEquation(
        _ initialConcentration: CGFloat,
        coefficient: Int,
        increases: Bool,
        unitChange: CGFloat,
        finalTime: CGFloat
    ) -> Equation {
        let unitChangeDirection = increases ? unitChange : -unitChange
        let finalConcentration = initialConcentration + (CGFloat(coefficient) * unitChangeDirection)
        return EquilibriumReactionEquation(
            t1: 0,
            c1: initialConcentration,
            t2: finalTime,
            c2: finalConcentration
        )
    }
}

extension BalancedReactionEquations {
    var equationArray: [Equation] {
        [reactantA, reactantB, productC, productD]
    }
}

extension BalancedReactionEquations {

    /// Returns whether the equation has a valid convergence
    ///
    /// For a reaction to be valid, all concentrations must be between 0 and 1 (exclusive) at the convergence time
    var isValid: Bool {
        equationArray.allSatisfy { isValid(reaction: $0) }
    }

    var reactantToAddForValidReaction: AqueousMoleculeReactant? {
        if reactantA.getY(at: convergenceTime) <= 0 {
            return .A
        } else if reactantB.getY(at: convergenceTime) <= 0 {
            return .B
        }
        return nil
    }

    private func isValid(reaction: Equation) -> Bool {
        let c = reaction.getY(at: convergenceTime)
        return c > 0 && c < 1
    }
}
