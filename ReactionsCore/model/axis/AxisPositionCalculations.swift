//
// Reactions App
//

import CoreGraphics

/// Encapsulates a linear axis, which moves from two positions and two values
public struct AxisPositionCalculations<Value: BinaryFloatingPoint> {
    public let minValuePosition: Value
    public let maxValuePosition: Value
    public let minValue: Value
    public let maxValue: Value

    public init(
        minValuePosition: Value,
        maxValuePosition: Value,
        minValue: Value,
        maxValue: Value
    ) {
        self.minValuePosition = minValuePosition
        self.maxValuePosition = maxValuePosition
        self.minValue = minValue
        self.maxValue = maxValue
    }

    public func getPosition(at value: Value) -> Value {
        return (m * value) + c
    }

    public func getValue(at position: Value) -> Value {
        return (position - c) / m
    }

    /// Returns the increment to use for accessibility
    public var accessibilityIncrement: Value {
        (maxValue - minValue) / 10
    }

    /// Returns a new axis with the minimum value updated to the provided value.
    /// The minimum value position is updated to keep the same axis scale
    public func updateMin(value: Value) -> AxisPositionCalculations<Value> {
        let valuePosition = getPosition(at: value)
        return withNewMin(position: valuePosition, value: value)
    }

    /// Returns a new axis with the minimum value position updated to the provided value.
    /// The minimum value is updated to keep the same axis scale
    public func updateMin(position: Value) -> AxisPositionCalculations<Value> {
        let valueForPosition = getValue(at: position)
        return withNewMin(position: position, value: valueForPosition)
    }

    /// Returns a new axis with the maximum value updated to the provided value.
    /// The maximum value position is updated to keep the same axis scale
    public func updateMax(value: Value) -> AxisPositionCalculations<Value> {
        let valuePosition = getPosition(at: value)
        return withNewMax(position: valuePosition, value: value)
    }

    /// Returns a new axis with the maximum value position updated to the provided value.
    /// The maximum value is updated to keep the same axis scale
    public func updateMax(position: Value) -> AxisPositionCalculations<Value> {
        let valueForPosition = getValue(at: position)
        return withNewMax(position: position, value: valueForPosition)
    }

    /// Returns a value which corresponds to the distance `distance`
    public func valueForDistance(_ distance: Value) -> Value {
        let scaledDistance = abs(distance / (maxValuePosition - minValuePosition))
        let dValue = maxValue - minValue
        return minValue + (scaledDistance * dValue)
    }

    private func withNewMin(position: Value, value: Value) -> AxisPositionCalculations<Value> {
        AxisPositionCalculations(
            minValuePosition: position,
            maxValuePosition: maxValuePosition,
            minValue: value,
            maxValue: maxValue
        )
    }

    private func withNewMax(position: Value, value: Value) -> AxisPositionCalculations<Value> {
        AxisPositionCalculations(
            minValuePosition: minValuePosition,
            maxValuePosition: position,
            minValue: minValue,
            maxValue: value
        )
    }

    private var m: Value {
        (maxValuePosition - minValuePosition) / (maxValue - minValue)
    }

    private var c: Value {
        minValuePosition - (m * minValue)
    }
}

extension AxisPositionCalculations {
    public func shift(by delta: Value) -> AxisPositionCalculations<Value> {
        AxisPositionCalculations(
            minValuePosition: minValuePosition,
            maxValuePosition: maxValuePosition,
            minValue: minValue + delta,
            maxValue: maxValue + delta
        )
    }
}
