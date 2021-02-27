//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct ReactionQuotientEquation: Equation {

    let equations: BalancedReactionEquations

    func getY(at x: CGFloat) -> CGFloat {
        func getTerm(_ equation: Equation, _ coeff: Int) -> CGFloat {
            pow(equation.getY(at: x), CGFloat(coeff))
        }

        let aTerm = getTerm(equations.reactantA, equations.coefficients.reactantACoefficient)
        let bTerm = getTerm(equations.reactantB, equations.coefficients.reactantBCoefficient)
        let cTerm = getTerm(equations.productC, equations.coefficients.productCCoefficient)
        let dTerm = getTerm(equations.productD, equations.coefficients.productDCoefficient)

        let numer = cTerm * dTerm
        let denom = aTerm * bTerm

        return denom == 0 ? 0 : numer / denom
    }
}

