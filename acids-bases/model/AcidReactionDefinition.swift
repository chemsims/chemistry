//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidReactionDefinition: Equatable {
    let leftTerms: [Term]
    let rightTerms: [Term]

    struct Term: Equatable {
        let name: TextLine
        let color: Color
    }
}
