//
// Reactions App
//

import ReactionsCore

struct Titrant {
    /// Display name of the titrant
    let name: String

    /// Color of the titrant when it is at its maximum molarity
    let maximumMolarityColor: RGB

    let primaryIonColor: RGB

    var accessibilityLabel: String {
        Labelling.stringToLabel(name)
    }
}

extension Titrant {
    static let potassiumHydroxide = Titrant(
        name: "KOH",
        maximumMolarityColor: .potassiumHydroxide,
        primaryIonColor: .hydroxide
    )

    static let hydrogenChloride = Titrant(
        name: "HCl",
        maximumMolarityColor: .hydrogenChloride,
        primaryIonColor: .hydrogen
    )
}
