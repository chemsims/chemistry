//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct ReactionConvergenceSolver {

    static let tolerance: CGFloat = 0.0001
    private static let maxIterations = 30

    /// Returns the unit change for which the equilibrium quotient will equal the equilibrium constant at the end of the reaction
    static func findUnitChangeFor(
        equilibriumConstant: CGFloat,
        coeffs: BalancedReactionCoefficients,
        initialConcentrations: BalancedReactionInitialConcentrations,
        isForward: Bool
    ) -> CGFloat? {
        let equation = ConvergingReactionQuotientEquation(coeffs: coeffs, initialConcentrations: initialConcentrations, isForward: isForward)

        let result = findSolution(
            k: equilibriumConstant,
            equation: equation,
            minX: 0,
            maxX: maxConcentrationDrop(equation: equation),
            qIncreasesWithX: isForward
        )

        return result
    }

    private static func findSolution(
        k: CGFloat,
        equation: ConvergingReactionQuotientEquation,
        minX: CGFloat,
        maxX: CGFloat,
        qIncreasesWithX: Bool
    ) -> CGFloat? {

        func loop(
            minX: CGFloat,
            maxX: CGFloat,
            iterations: Int
        ) -> CGFloat? {
            let midPoint = (maxX + minX) / 2
            let result = equation.getY(at: midPoint)

            if abs(result - k) <= Self.tolerance {
                return midPoint
            }

            if iterations >= Self.maxIterations {
                return nil
            }

            if (result < k) {
                return loop(
                    minX: qIncreasesWithX ? midPoint : minX,
                    maxX: qIncreasesWithX ? maxX : midPoint,
                    iterations: iterations + 1
                )
            }
            return loop(
                minX: qIncreasesWithX ? minX : midPoint,
                maxX: qIncreasesWithX ? midPoint : maxX,
                iterations: iterations + 1
            )
        }

        return loop(minX: minX, maxX: maxX, iterations: 0)
    }

    private static func maxConcentrationDrop(
        equation: ConvergingReactionQuotientEquation
    ) -> CGFloat {
        if equation.isForward {
            let aDelta = equation.initialConcentrations.reactantA / CGFloat(equation.coeffs.reactantA)
            let bDelta = equation.initialConcentrations.reactantB / CGFloat(equation.coeffs.reactantB)
            return min(aDelta, bDelta)
        }
        let cDelta = equation.initialConcentrations.productC / CGFloat(equation.coeffs.productC)
        let dDelta = equation.initialConcentrations.productD / CGFloat(equation.coeffs.productD)
        return min(cDelta, dDelta)
    }
}

/// Reaction quotient equation for at the end of a reaction, in terms of the unit change in concentration
///
/// For example, given the reaction 2A + 2B -> C + 4B, the quotient at the end of a reaction is:
/// Q = (c0 + CcX)^Cc * (d0 + CdX)^Cd / (a0 - CaX)^Ca * (b0 - CbX)^Cb
/// where X is the unit change, n0 is the initial concentration of n, and Cn is the coefficient of n
///
/// For the reverse reaction, the equation is the same except that the reactant concentrations increase, and products decrease.
/// Also, note that in this case the initial concentrations are the concentrations at the start of the reverse reaction.
private struct ConvergingReactionQuotientEquation: Equation {

    let coeffs: BalancedReactionCoefficients
    let initialConcentrations: BalancedReactionInitialConcentrations
    let isForward: Bool

    func getY(at x: CGFloat) -> CGFloat {
        let aTerm = reactantTerm(x: x, coeffs.reactantA, initialConcentrations.reactantA)
        let bTerm = reactantTerm(x: x, coeffs.reactantB, initialConcentrations.reactantB)
        let cTerm = productTerm(x: x, coeffs.productC, initialConcentrations.productC)
        let dTerm = productTerm(x: x, coeffs.productD, initialConcentrations.productD)

        let numer = cTerm * dTerm
        let denom = aTerm * bTerm

        return numer / denom
    }

    private func reactantTerm(
        x: CGFloat,
        _ coefficient: Int,
        _ initialConcentration: CGFloat
    ) -> CGFloat {
        getTerm(x: x, coefficient, initialConcentration, increases: !isForward)
    }

    private func productTerm(
        x: CGFloat,
        _ coefficient: Int,
        _ initialConcentration: CGFloat
    ) -> CGFloat {
        getTerm(x: x, coefficient, initialConcentration, increases: isForward)
    }

    private func getTerm(
        x: CGFloat,
        _ coefficient: Int,
        _ initialConcentration: CGFloat,
        increases: Bool
    ) -> CGFloat {
        let coeffCGFloat = CGFloat(coefficient)
        let increaseFactor: CGFloat = increases ? 1 : -1
        return pow(initialConcentration + (coeffCGFloat * x * increaseFactor), coeffCGFloat)
    }
}

