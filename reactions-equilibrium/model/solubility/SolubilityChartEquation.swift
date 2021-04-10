//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SolubilityChartEquation: Equation {

    private let underlyingLeft: QuadraticEquation
    private let underlyingRight: QuadraticEquation

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
        self.underlyingLeft = QuadraticEquation(
            parabola: parabola,
            through: CGPoint(x: 0, y: zeroPhSolubility)
        )
        self.underlyingRight = QuadraticEquation(
            parabola: parabola,
            through: CGPoint(x: 1, y: maxPhSolubility)
        )
    }

    private var underlying: Equation {
        SwitchingEquation(
            thresholdX: phAtMinSolubility,
            underlyingLeft: underlyingLeft,
            underlyingRight: underlyingRight
        )
    }

    func getY(at x: CGFloat) -> CGFloat {
        underlying.getY(at: x)
    }

    func getLeftHandPh(for solubility: CGFloat) -> CGFloat? {
        func isValid(_ result: CGFloat) -> Bool {
            result > 0 && result < phAtMinSolubility
        }

        return underlyingLeft.getX(for: solubility).flatMap { results in
            if isValid(results.0) {
                return results.0
            } else if isValid(results.1) {
                return results.1
            }
            return nil
        }
    }
}
