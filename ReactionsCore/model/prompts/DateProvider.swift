//
// Reactions App
//

import Foundation

/// Provides the current date.
///
/// Used to inject different dates for testing
protocol DateProvider {
    func now() -> Date
}

class CurrentDateProvider: DateProvider {
    func now() -> Date {
        Date()
    }
}
