//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct SolubilityQuotientEquation: Equation {

    let concentration: SoluteValues<Equation>

    func getValue(at x: CGFloat) -> CGFloat {
        let values = concentration.map { $0.getValue(at: x) }
        return values.productA * values.productB
    }
}
