//
// Reactions App
//

import CoreGraphics

public func within<Value: Comparable>(min: Value, max: Value, value: Value) -> Value {
    Swift.min(max, Swift.max(min, value))
}

public func identity<Value>(value: Value) -> Value {
    value
}

/// Returns log base 10 of the value if it is above 0, else returns 0
public func safeLog10(_ value: CGFloat) -> CGFloat {
    value <= 0 ? 0 : log10(value)
}

var isAtLeastIOS14: Bool {
    if #available(iOS 14.0, *) {
        return true
    } else {
        return false
    }
}
