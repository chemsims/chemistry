//
// Reactions App
//


import SwiftUI

public struct SliderHapticsHandler<Value: BinaryFloatingPoint> {

    let axis: LinearAxis<Value>
    let impactGenerator: UIImpactFeedbackGenerator

    public init(axis: LinearAxis<Value>, impactGenerator: UIImpactFeedbackGenerator) {
        self.axis = axis
        self.impactGenerator = impactGenerator
    }

    /// Triggers a haptic impact when the `newValue` exceeds the axis limits, and
    /// prepares the generator when value is close to the limits.
    public func valueDidChange(
        newValue: Value,
        oldValue: Value
    ) {
        if newValue > oldValue {
            if newValue >= axis.maxValue {
                impactGenerator.impactOccurred()
            } else if newValue >= 0.75 * axis.maxValue {
                impactGenerator.prepare()
            }
        } else if newValue < oldValue {
            if newValue <= axis.minValue {
                impactGenerator.impactOccurred()
            } else if newValue <= 1.25 * axis.minValue {
                impactGenerator.prepare()
            }
        }
    }
}
