//
// Reactions App
//

import Foundation

public typealias EnumMappable = CaseIterable & Hashable

/// A struct which provides a guaranteed map lookup for keys which conform to `CaseIterable`.
public struct EnumMap<Key, Value> where Key : CaseIterable, Key : Hashable {

    /// Creates a new map instance with the provided `builder`.
    ///
    /// - Note: The builder function is executed immediately for each `Key.allCases`, and the
    /// results stored.
    public init(
        builder: (Key) -> Value
    ) {
        var values = [Key : Value]()
        Key.allCases.forEach { element in
            values[element] = builder(element)
        }
        self.values = values
    }

    /// Creates a new instant using `value` for each element
    public static func constant(_ value: Value) -> EnumMap<Key, Value> {
        EnumMap(builder: { _ in value })
    }

    private let values: [Key : Value]

    /// Returns a value for the given element
    public func value(for element: Key) -> Value {
        // We can force unwrap here, since `values` is guaranteed to contain `element`,
        // as it is constructed in the initialised from `Key.allCases`.
        values[element]!
    }

    /// Returns a new map with the values passed through the given `transform` function
    public func map<MappedValue>(
        _ transform: (Value) -> MappedValue
    ) -> EnumMap<Key, MappedValue> {
        EnumMap<Key, MappedValue> { element in
            transform(value(for: element))
        }
    }

    /// Returns a new map where the values of this map are combined with the `other` map,
    /// using the given  `combiner` function
    public func combine<OtherValue, MappedValue>(
        with other: EnumMap<Key, OtherValue>,
        using combiner: (Value, OtherValue) -> MappedValue
    ) -> EnumMap<Key, MappedValue> {
        EnumMap<Key, MappedValue> { element in
            let lhs = value(for: element)
            let rhs = other.value(for: element)
            return combiner(lhs, rhs)
        }
    }

    /// Returns all values in the same order as `Key.allCases`
    public var all: [Value] {
        Key.allCases.map(value)
    }
}

extension EnumMap where Key: Equatable {
    /// Returns a new map where `element` has the value `newValue`
    public func updating(with newValue: Value, for element: Key) -> EnumMap<Key, Value> {
        EnumMap {
            $0 == element ? newValue : value(for: $0)
        }
    }
}

extension EnumMap : Equatable where Key : Equatable, Value : Equatable {
}
