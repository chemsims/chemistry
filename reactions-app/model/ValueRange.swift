//
// Reactions App
//
  

import Foundation

struct ValueRange<Value> where Value: BinaryFloatingPoint {
    let value: Value
    let minValue: Value
    let maxValue: Value

    var percentage: Value {
        value / (maxValue - minValue)
    }
}
