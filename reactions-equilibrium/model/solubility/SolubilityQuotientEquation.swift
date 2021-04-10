//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct SolubilityQuotientEquation: Equation {

    let concentration: SoluteValues<Equation>

    func getY(at x: CGFloat) -> CGFloat {
        let values = concentration.map { $0.getY(at: x) }
        return values.productA * values.productB
    }
}
