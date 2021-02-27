//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct ReactionQuotientEquation: Equation {

    let equations: BalancedReactionEquations

    /// Number of decimals places to round concentrations to before using in calculations
    ///
    /// Rounding the decimals before using in calculations can be important when displaying the values to the user.
    ///
    /// Consider that the user scrubs to a specific point in the reaction, and tries to evaluate the equation they see on their own
    /// calculator. Since the values they use are rounded, the result they get could be significantly different to the result obtained
    /// if the raw values are used
    let decimals: Int?

    init(equations: BalancedReactionEquations, decimals: Int? = nil) {
        self.equations = equations
        self.decimals = decimals
    }

    func getY(at x: CGFloat) -> CGFloat {
        func getTerm(_ equation: Equation, _ coeff: Int) -> CGFloat {
            let y = equation.getY(at: x)
            let rounded = decimals.map { y.rounded(decimals: $0) } ?? y
            return pow(rounded, CGFloat(coeff))
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

