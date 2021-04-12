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
    let highlightForwardArrow: Bool
    let highlightReverseArrow: Bool
    let showHeat: Bool
    let reactionDefinitionHighlight: Color
    let generalElementHighlight: Color
    let settings: AqueousScreenLayoutSettings

    var body: some View {
        HStack(spacing: 0) {
            if !isSelectingReaction {
                ReactionDefinitionView<Reaction>(
                    type: selectedReaction,
                    highlightTopArrow: highlightForwardArrow,
                    highlightReverseArrow: highlightReverseArrow,
                    showHeat: showHeat
                )
                .font(.system(size: settings.reactionDefintionFont))
                .minimumScaleFactor(0.5)
                .colorMultiply(reactionDefinitionHighlight)
            }

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
            .colorMultiply(generalElementHighlight)
        }
        .frame(width: settings.gridWidth, height: settings.reactionToggleHeight)
        .zIndex(isSelectingReaction ? 1 : 0)
    }
}

