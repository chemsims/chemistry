//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SelectionToggleText: View {

    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(text)
            .foregroundColor(
                isSelected ? .orangeAccent : Styling.inactiveScreenElement
            )
            .onTapGesture(perform: action)
            .lineLimit(1)
            .accessibility(addTraits: .isButton)
            .accessibility(addTraits: isSelected ? [.isSelected] : [])
    }
}
