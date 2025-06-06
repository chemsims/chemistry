//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ReactionToggle<Reaction: SelectableReaction>: View {

    let reactions: [Reaction]
    @Binding var selectedReaction: Reaction
    @Binding var reactionSelectionIsToggled: Bool
    let isSelectingReaction: Bool
    let onSelection: (() -> Void)?
    let reactionToggleHighlight: Color
    let settings: EquilibriumAppLayoutSettings

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            ReactionDropDownSelection(
                isToggled: $reactionSelectionIsToggled,
                selection: $selectedReaction,
                options: reactions,
                onSelection: onSelection,
                height: settings.reactionToggleHeight
            )
            .frame(
                width: settings.reactionToggleHeight,
                height: settings.reactionToggleHeight,
                alignment: .topTrailing
            )
            .disabled(!isSelectingReaction)
            .opacity(isSelectingReaction ? 1 : 0.6)
            .colorMultiply(reactionToggleHighlight)
        }
        .frame(width: settings.gridWidth, height: settings.reactionToggleHeight)
        .zIndex(isSelectingReaction ? 1 : 0)
    }
}

