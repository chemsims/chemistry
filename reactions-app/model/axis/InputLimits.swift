//
// Reactions App
//
  

import CoreGraphics

struct InputLimits: Equatable {
    let min: CGFloat
    let max: CGFloat
    let smallerOtherValue: CGFloat?
    let largerOtherValue: CGFloat?
}

struct InputRange {
    let min: CGFloat
    let max: CGFloat
    let minInputRange: CGFloat
    let valueSpacing: CGFloat
}
