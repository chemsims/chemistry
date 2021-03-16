//
// Reactions App
//

import SwiftUI
import ReactionsCore

class GaseousReactionViewModel: ObservableObject {

    @Published var highlightedElements = HighlightedElements<GaseousScreenElement>()

}
