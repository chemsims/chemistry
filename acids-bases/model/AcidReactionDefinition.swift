//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidReactionDefinition {
    let leftTerms: [Term]
    let rightTerms: [Term]

    struct Term {
        let name: TextLine
        let color: Color
    }
}
