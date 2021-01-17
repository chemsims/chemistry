//
// Reactions App
//
  

import CoreGraphics

protocol InputLimits {

    /// Minimum input value
    var min: CGFloat { get }

    /// Maximum input value
    var max: CGFloat { get }

    /// The safe area defines an input area where no other input should overlap
    var safeAreaSize: CGFloat { get }
}

extension InputLimits {
    var lowerSafeAreaEnd: CGFloat {
        min + safeAreaSize
    }

    var upperSafeAreaStart: CGFloat {
        max - safeAreaSize
    }
}

struct FixedInputLimits: InputLimits {
    let min: CGFloat
    let max: CGFloat
    let safeAreaSize: CGFloat
}
