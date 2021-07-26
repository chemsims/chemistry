//
// Reactions App
//

import SwiftUI

struct AcidAppSettings {
    static let minBeakerRows = 7
    static let maxBeakerRows = 15
    static let initialRows = (minBeakerRows + maxBeakerRows) / 2

    static let maxReactionProgressMolecules = 10

    static let minTitrantMolarity: CGFloat = 0.2
    static let maxTitrantMolarity: CGFloat = 0.5
    static let initialTitrantMolarity = (minTitrantMolarity + maxTitrantMolarity) / 2

    static let weakTitrationInitialReactionDuration: TimeInterval = 2
}

extension AcidAppSettings {
    struct MacroBeaker {

        /// Number of titrant molecules to add when the color
        /// is changing sharpl
        static let titrantToAddDuringSharpColorChange = 5

        /// How much the beaker color should change prior to the sharp point
        static let colorTurningPointProgress: CGFloat = 0.2
    }
}
