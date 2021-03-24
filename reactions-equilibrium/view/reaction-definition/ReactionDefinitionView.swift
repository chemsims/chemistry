//
// Reactions App
//

import SwiftUI

struct ReactionDefinitionView<Reaction: ReactionDefinition>: View {

    let type: Reaction
    let highlightTopArrow: Bool
    let highlightReverseArrow: Bool

    var body: some View {
        HStack(spacing: 5) {
            Text(type.reactantDisplay)
            DoubleSidedArrow(
                topHighlight: highlightTopArrow ? .orangeAccent : nil,
                reverseHighlight: highlightReverseArrow ? .orangeAccent : nil
            )
            Text(type.productDisplay)
        }
    }
}

struct AqueousReactionTypeView_Previews: PreviewProvider {
    static var previews: some View {
        ReactionDefinitionView(type: AqueousReactionType.A, highlightTopArrow: false, highlightReverseArrow: true)
    }
}
