//
// Reactions App
//

import CoreGraphics
import ReactionsCore

/// An equation which varies between two concentrations over a period of time, using a quadratic curve
struct EquilibriumReactionEquation: Equation {

    private let underlying: Equation

    init(
        t1: CGFloat,
        c1: CGFloat,
        t2: CGFloat,
        c2: CGFloat
    ) {
        underlying = SwitchingEquation(
            thresholdX: t2,
            underlyingLeft: QuadraticEquation(
                parabola: CGPoint(x: t2, y: c2),
                through: CGPoint(x: t1, y: c1)
            ),
            underlyingRight: ConstantEquation(value: c2)
        )
    }

    func getValue(at x: CGFloat) -> CGFloat {
        let res = underlying.getValue(at: x)
        // There's an issue where very small concentrations could appear as a negative zero
        if (abs(res) < 0.000000001) {
            return 0
        }
        return res
    }

}
