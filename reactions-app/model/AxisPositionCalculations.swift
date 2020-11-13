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

    private var m: Value {
        (maxValuePosition - minValuePosition) / (maxValue - minValue)
    }

    private var c: Value {
        minValuePosition - (m * minValue)
    }
}
