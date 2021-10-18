//
// Reactions App
//

import Foundation

struct Flags {

    /// Note, currently we automatically opt in or out on every app launch, depending on the users region.
    /// So, if we add the opt-out toggle again, we must make sure to change the app launch behaviour so that
    /// we don't override the users choice.
    static let showAnalyticsOptOutToggle = false
}
