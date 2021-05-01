//
// Reactions App
//

import SwiftUI

struct ReactionDefinitionView<Reaction: SelectableReaction>: View {

    let type: Reaction
    let runForwardArrow: Bool
    let runReverseArrow: Bool
    let arrowWidth: CGFloat

    var body: some View {
        HStack(spacing: 5) {
            Text(type.reactantDisplay)
            AnimatingDoubleSidedArrow(
                width: arrowWidth,
                runForward: runForwardArrow,
                runReverse: runReverseArrow
            )
            Text(type.productDisplay)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
    }

    private var label: String {
        "\(type.reactantLabel) double-sided arrow \(type.productLabel)"
    }
}

struct AqueousReactionTypeView_Previews: PreviewProvider {
    static var previews: some View {
        ReactionDefinitionView(
            type: AqueousReactionType.A,
            runForwardArrow: false,
            runReverseArrow: true,
            arrowWidth: 15
        )
    }
}
