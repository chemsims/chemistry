//
// Reactions App
//

import ReactionsCore

struct Titrant {
    /// Display name of the titrant
    let name: String

    /// Color of the titrant when it is at its maximum molarity
    let maximumMolarityColor: RGB
}

extension Titrant {
    static let potassiumHydroxide = Titrant(
        name: "KOH",
        maximumMolarityColor: .hydroxide
    )
}
