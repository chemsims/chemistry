//
// Reactions App
//


import Foundation

// A property wrapper to wrap a value type so it can
// be used recursively
// From https://forums.swift.org/t/recursive-structs/30557

@propertyWrapper
public class Indirect<T> {
    public var wrappedValue: T
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}
