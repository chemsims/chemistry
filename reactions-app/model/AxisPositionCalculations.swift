//
// Reactions App
//
  

import Foundation

/// Encapsulates a linear axis, which moves from two positions and two values
struct AxisPositionCalculations<Value: BinaryFloatingPoint> {
    let minValuePosition: Value
    let maxValuePosition: Value
    let minValue: Value
    let maxValue: Value

    func getPosition(at value: Value) -> Value {
        return (m * value) + c
    }

    func getValue(at position: Value) -> Value {
        return (position - c) / m
    }

    /// Returns a new axis with the minimum value updated to the provided value.
    /// The minimum value position is updated to keep the same axis scale
    func updateMin(value: Value) -> AxisPositionCalculations<Value> {
        let valuePosition = getPosition(at: value)
        return withNewMin(position: valuePosition, value: value)
    }

    /// Returns a new axis with the minimum value position updated to the provided value.
    /// The minimum value is updated to keep the same axis scale
    func updateMin(position: Value) -> AxisPositionCalculations<Value> {
        let valueForPosition = getValue(at: position)
        return withNewMin(position: position, value: valueForPosition)
    }

    /// Returns a new axis with the maximum value updated to the provided value.
    /// The maximum value position is updated to keep the same axis scale
    func updateMax(value: Value) -> AxisPositionCalculations<Value> {
        let valuePosition = getPosition(at: value)
        return withNewMax(position: valuePosition, value: value)
    }

    /// Returns a new axis with the maximum value position updated to the provided value.
    /// The maximum value is updated to keep the same axis scale
    func updateMax(position: Value) -> AxisPositionCalculations<Value> {
        let valueForPosition = getValue(at: position)
        return withNewMax(position: position, value: valueForPosition)
    }

    /// Returns a value which corresponds to the distance `distance`
    func valueForDistance(_ distance: Value) -> Value {
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
