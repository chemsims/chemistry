//
// Reactions App
//

import ReactionsCore

struct Titrant {
    /// Display name of the titrant
    let name: String

    /// Color of the titrant when it is at its maximum molarity
    let maximumMolarityColor: RGB

    var accessibilityLabel: String {
        Labelling.stringToLabel(name)
    }
}

extension Titrant {
    static let potassiumHydroxide = Titrant(
        name: "KOH",
        maximumMolarityColor: .hydroxide
    )

    static let hydrogenChloride = Titrant(
        name: "HCl",
        maximumMolarityColor: .hydrogen
    )
}
