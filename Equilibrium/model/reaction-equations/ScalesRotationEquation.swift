//
// Reactions App
//

import ReactionsCore
import CoreGraphics

struct ScalesRotationEquation: Equation {

    private let fraction: Equation
    private let maxAngle: CGFloat

    init(
        fraction: Equation,
        maxAngle: CGFloat
    ) {
        self.fraction = fraction
        self.maxAngle = maxAngle
    }

    func getValue(at x: CGFloat) -> CGFloat {
        fraction.getValue(at: x) * maxAngle
    }
}

struct InitialAngleValue {
    let currentValue: CGFloat
    let valueAtZeroAngle: CGFloat
    let valueAtMaxAngle: CGFloat
    let isNegative: Bool

    init(
        currentValue: CGFloat,
        valueAtZeroAngle: CGFloat,
        valueAtMaxAngle: CGFloat,
        isNegative: Bool = false
    ) {
        self.currentValue = currentValue
        self.valueAtZeroAngle = valueAtZeroAngle
        self.valueAtMaxAngle = valueAtMaxAngle
        self.isNegative = isNegative
    }

    var fraction: CGFloat {
        guard valueAtMaxAngle != valueAtZeroAngle else {
            return 0
        }
        let returnValue = (currentValue - valueAtZeroAngle) / (valueAtMaxAngle - valueAtZeroAngle)
        let direction: CGFloat = isNegative ? -1 : 1
        return returnValue * direction
    }
}
