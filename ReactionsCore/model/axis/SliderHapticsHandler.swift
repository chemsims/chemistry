//
// Reactions App
//


import SwiftUI

public struct SliderHapticsHandler<Value: BinaryFloatingPoint> {

    let axis: AxisPositionCalculations<Value>
    let impactGenerator: UIImpactFeedbackGenerator

    public init(axis: AxisPositionCalculations<Value>, impactGenerator: UIImpactFeedbackGenerator) {
        self.axis = axis
        self.impactGenerator = impactGenerator
    }

    /// Handles the haptics by preparing or firing the
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
