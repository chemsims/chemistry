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
}

extension Array where Element: Collection {

    public var flatten: [Element.Element] {
        self.reduce(into: [Element.Element]()) { (acc, next) in
            acc.append(contentsOf: next)
        }
    }
}
