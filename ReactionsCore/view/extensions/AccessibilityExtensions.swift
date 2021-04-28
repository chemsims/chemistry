//
// Reactions App
//

import Foundation
import SwiftUI

extension View {
    public func accessibilityToggle(
        isOn: Binding<Bool>,
        label: String,
        value: @escaping (Bool) -> String
    ) -> some View {
        self.modifier(
            AccessibilityToggleViewModifier(
                isOn: isOn,
                label: label,
                value: value
            )
        )
    }
}

private struct AccessibilityToggleViewModifier: ViewModifier {
    @Binding var isOn: Bool
    let label: String
    let value: (Bool) -> String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibility(addTraits: .isButton)
            .accessibility(label: Text(label))
            .accessibility(value: Text(value(isOn)))
            .accessibilityAction {
                isOn.toggle()
            }
    }
}
