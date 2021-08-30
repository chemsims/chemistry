//
// Reactions App
//

import Foundation
@testable import ReactionsCore

struct FixedDateProvider: DateProvider {
    let date: Date

    func now() -> Date {
        date
    }
}
