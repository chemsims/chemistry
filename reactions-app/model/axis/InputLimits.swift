//
// Reactions App
//
  

import CoreGraphics

protocol InputLimits {

    /// Minimum input value
    var min: CGFloat { get }

    /// Maximum input value
    var max: CGFloat { get }

    var largerOtherValue: CGFloat? { get }

    var smallerOtherValue: CGFloat? { get }
}


struct FixedInputLimits: InputLimits, Equatable {
    let min: CGFloat
    let max: CGFloat
    let smallerOtherValue: CGFloat?
    let largerOtherValue: CGFloat?
}
