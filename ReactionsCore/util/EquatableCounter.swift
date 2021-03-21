//
// Reactions App
//

import Foundation

/// A counter which increases against a specific value, and resets when the value changes
///
/// Incrementing the counter for the same value will maintain the count, while different values will reset the count
public struct EquatableCounter<Value: Equatable> {

    private var value: Value?
    public private(set) var count: Int

    /// Creates an empty counter
    public init() {
        self.init(value: nil, count: 0)
    }

    private init(value: Value?, count: Int) {
        self.value = value
        self.count = count
    }

    /// Increment the counter for the value `value`
    ///
    /// If the current counter value is the same, the count will be incremented by 1.
    /// Otherwise, the counter will be reset to 0, and then incremented by 1.
    public mutating func increment(value: Value) {
        if let v = self.value, v == value {
            count += 1
        } else {
            self.value = value
            count = 1
        }
    }

    public mutating func reset() {
        value = nil
        count = 0
    }
}
