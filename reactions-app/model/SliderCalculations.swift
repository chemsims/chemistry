//
// Reactions App
//
  

import Foundation

struct SliderCalculations<Value> where Value: BinaryFloatingPoint {
    let minValuePosition: Value
    let maxValuePosition: Value
    let minValue: Value
    let maxValue: Value

    func getHandleCenter(at value: Value) -> Value {
        let percValue = (value - minValue) / (maxValue - minValue)
        return (percValue * (maxValuePosition - minValuePosition)) + minValuePosition
    }

    func getValue(forHandle position: Value) -> Value {
        let percPosition = (position - minValuePosition) / (maxValuePosition - minValuePosition)
        return (percPosition * (maxValue - minValue)) + minValue
    }

}
