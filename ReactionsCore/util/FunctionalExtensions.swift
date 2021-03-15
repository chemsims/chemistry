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
