//
// Reactions App
//

import Foundation

/// Extensions to port over useful functional programming APIs - mainly from Scala

extension Optional {

    /// Applies predicate on value, or true if empty
    public func forAll(_ p: (Wrapped) -> Bool) -> Bool {
        self.map { p($0) } ?? true
    }

    /// Applies predicate on value if it exists, or false if empty
    public func exists(_ p: (Wrapped) -> Bool) -> Bool {
        self.map { p($0) } ?? false
    }
}

extension Optional where Wrapped: Equatable {
    /// Returns true if a value exists and it is equal to `other`
    public func contains(_ other: Wrapped) -> Bool {
        self.exists { $0 == other }
    }
}

extension Array where Element: Collection {

    public var flatten: [Element.Element] {
        self.reduce(into: [Element.Element]()) { (acc, next) in
            acc.append(contentsOf: next)
        }
    }
}
