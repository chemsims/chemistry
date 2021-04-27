//
// Reactions App
//

import SwiftUI

struct ReactionDefinitionView<Reaction: SelectableReaction>: View {

    let type: Reaction
    let runForwardArrow: Bool
    let runReverseArrow: Bool

    var body: some View {
        HStack(spacing: 5) {
            Text(type.reactantDisplay)
            AnimatingDoubleSidedArrow(
                width: 15,
                runForward: runForwardArrow,
                runReverse: runReverseArrow
            )
            Text(type.productDisplay)
        }
    }
}

struct AqueousReactionTypeView_Previews: PreviewProvider {
    static var previews: some View {
        ReactionDefinitionView(
            type: AqueousReactionType.A,
            runForwardArrow: false,
            runReverseArrow: true
        )
    }
}
