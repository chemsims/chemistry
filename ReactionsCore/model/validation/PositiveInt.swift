//
// Reactions App
//

import Foundation

public struct PositiveInt: Equatable {

    public init?(_ value: Int) {
        guard value >= 0 else {
            return nil
        }
        self.value = value
    }

    // This uses `Int` over `UInt` as the Swift Language Guide recommends using `Int`
    // unless we care about the size, which we don't
    // https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html
    public let value: Int
}

public struct NonZeroPositiveInt: Equatable {

    public init?(_ value: Int) {
        guard value > 0 else {
            return nil
        }
        self.value = value
    }

    public let value: Int

    public var positiveInt: PositiveInt {
        PositiveInt(value)!
    }
}
