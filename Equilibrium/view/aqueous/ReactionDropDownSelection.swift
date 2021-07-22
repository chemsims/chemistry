//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ReactionDropDownSelection<Reaction: SelectableReaction>: View {

    @Binding var isToggled: Bool
    @Binding var selection: Reaction
    let options: [Reaction]
    let onSelection: (() -> Void)?
    let height: CGFloat

    var body: some View {
        DropDownSelectionView(
            title: "Choose a reaction",
            options: options,
            isToggled: $isToggled,
            selection: $selection,
            height: height,
            animation: .easeOut(duration: 0.75),
            displayString: { TextLine($0.displayName) },
            label: { $0.label },
            disabledOptions: [],
            onSelection: onSelection
        )
    }
}

struct AqueousReactionDropDownSelection_Previews: PreviewProvider {
    static var previews: some View {
        ReactionDropDownSelection(
            isToggled: .constant(true),
            selection: .constant(.A),
            options: AqueousReactionType.allCases,
            onSelection: nil,
            height: 50
        )
    }
}
