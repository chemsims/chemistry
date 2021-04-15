//
// Reactions App
//

import Foundation

/// A container for a value, which records the previously set value
public struct ValueWithPrevious<Value: Equatable> {

    public init(value: Value) {
        self.value = value
    }

    public private(set) var value: Value

    public private(set) var oldValue: Value?

    /// Sets the value to the provided value, and moves the current value to the old value
    ///
    /// - Note: Calls to this function are ignored when the new value equals the current value
    public mutating func setValue(_ newValue: Value) {
        guard newValue != value else {
            return
        }
        oldValue = value
        value = newValue
    }
}
