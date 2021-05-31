//
// Reactions App
//

import SwiftUI

public struct SelectionToggleText: View {

    public init(
        text: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.isSelected = isSelected
        self.action = action
    }

    let text: String
    let isSelected: Bool
    let action: () -> Void

    public var body: some View {
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
