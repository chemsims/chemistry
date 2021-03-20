//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct ReactionQuotientEquation: Equation {

    let terms: MoleculeValue<QuotientTerm>

    init(equations: NewBalancedReactionEquation) {
        self.init(coefficients: equations.coefficients, equations: equations.concentration)
    }

    init(coefficients: MoleculeValue<Int>, equations: MoleculeValue<Equation>) {
        self.init(
            terms: equations.combine(
                with: coefficients,
                using: { QuotientTerm(equation: $0, coefficient: $1) }
            )
        )
    }

    init(terms: MoleculeValue<QuotientTerm>) {
        self.terms = terms
    }

    func getY(at x: CGFloat) -> CGFloat {
        func getTerm(_ term: QuotientTerm) -> CGFloat {
            let equation = term.equation
            let coeff = term.coefficient
            let y = equation.getY(at: x)
            return pow(y, CGFloat(coeff))
        }

        let aTerm = getTerm(terms.reactantA)
        let bTerm = getTerm(terms.reactantB)
        let cTerm = getTerm(terms.productC)
        let dTerm = getTerm(terms.productD)

        let numer = cTerm * dTerm
        let denom = aTerm * bTerm

        return denom == 0 ? 0 : numer / denom
    }
}

struct QuotientTerm {
    let equation: Equation
    let coefficient: Int
}
