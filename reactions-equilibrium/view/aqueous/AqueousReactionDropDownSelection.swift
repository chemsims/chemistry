//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AqueousReactionDropDownSelection: View {

    @Binding var isToggled: Bool
    @Binding var selection: AqueousReactionType
    let onSelection: (() -> Void)?
    let height: CGFloat

    var body: some View {
        DropDownSelectionView(
            title: "Choose a reaction",
            options: AqueousReactionType.allCases,
            isToggled: $isToggled,
            selection: $selection,
            height: height,
            animation: .easeOut(duration: 0.75),
            displayString: { $0.displayName },
            label: { $0.label },
            disabledOptions: [],
            onSelection: onSelection
        )
    }
}

struct AqueousReactionDropDownSelection_Previews: PreviewProvider {
    static var previews: some View {
        AqueousReactionDropDownSelection(
            isToggled: .constant(true),
            selection: .constant(.A),
            onSelection: nil,
            height: 50
        )
    }
}
