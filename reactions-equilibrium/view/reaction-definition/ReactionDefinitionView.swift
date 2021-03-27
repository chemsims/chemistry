//
// Reactions App
//

import SwiftUI

struct ReactionDefinitionView<Reaction: ReactionDefinition>: View {

    let type: Reaction
    let highlightTopArrow: Bool
    let highlightReverseArrow: Bool
    let showHeat: Bool

    var body: some View {
        HStack(spacing: 5) {
            if showHeat {
                Text("Heat +")
                    .foregroundColor(.orangeAccent)
            }

            Text(type.reactantDisplay)
            arrow
            Text(type.productDisplay)
        }
        .background(Color.white.padding(-10))
    }

    private var arrow: some View {
        VStack(spacing: 3) {
            if showHeat {
                deltaH(positive: true)
            }
            DoubleSidedArrow(
                topHighlight: highlightTopArrow ? .orangeAccent : nil,
                reverseHighlight: highlightReverseArrow ? .orangeAccent : nil
            )
            if showHeat {
                deltaH(positive: false)
            }
        }
    }

    private func deltaH(positive: Bool) -> some View {
        Text("\(positive ? "" : "-")ΔH")
            .foregroundColor(.orangeAccent)
    }
}

struct AqueousReactionTypeView_Previews: PreviewProvider {
    static var previews: some View {
        ReactionDefinitionView(
            type: AqueousReactionType.A,
            highlightTopArrow: false,
            highlightReverseArrow: true,
            showHeat: true
        )
    }
}
