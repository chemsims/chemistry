//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityPhComponents {

    let curve: SolubilityChartEquation
    let timing: ReactionTiming

    var startPh: CGFloat {
        0.85
    }

    var ph: Equation {
        ConstantEquation(value: startPh)
    }

    var solubility: Equation {
        SwitchingEquation(
            thresholdX: timing.equilibrium,
            underlyingLeft: notSaturatedSolubility,
            underlyingRight: saturatedSolubility
        )
    }

    private var notSaturatedSolubility: Equation {
        EquilibriumReactionEquation(
            t1: timing.start,
            c1: 0,
            t2: timing.end,
            c2: curve.getY(at: startPh)
        )
    }

    private var saturatedSolubility: Equation {
        LinearEquation(
            x1: timing.equilibrium,
            y1: saturatedPh,
            x2: timing.end,
            y2: min(0.9, 1.5 * saturatedPh)
        )
    }

    private var saturatedPh: CGFloat {
        curve.getY(at: startPh)
    }

}

struct SolubilityChartEquation: Equation {

    private let underlying: Equation

    let zeroPhSolubility: CGFloat
    let maxPhSolubility: CGFloat
    let minSolubility: CGFloat
    let phAtMinSolubility: CGFloat


    init(
        zeroPhSolubility: CGFloat,
        maxPhSolubility: CGFloat,
        minSolubility: CGFloat,
        phAtMinSolubility: CGFloat
    ) {
        self.zeroPhSolubility = zeroPhSolubility
        self.maxPhSolubility = maxPhSolubility
        self.minSolubility = minSolubility
        self.phAtMinSolubility = phAtMinSolubility

        let parabola = CGPoint(x: phAtMinSolubility, y: minSolubility)
        self.underlying = SwitchingEquation(
            thresholdX: phAtMinSolubility,
            underlyingLeft: QuadraticEquation(
                parabola: parabola,
                through: CGPoint(x: 0, y: zeroPhSolubility)
            ),
            underlyingRight: QuadraticEquation(
                parabola: parabola,
                through: CGPoint(x: 1, y: maxPhSolubility)
            )
        )
    }

    func getY(at x: CGFloat) -> CGFloat {
        underlying.getY(at: x)
    }
}
