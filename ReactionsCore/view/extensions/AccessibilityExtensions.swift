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

    public func accessibilitySetCurrentTimeAction(
        currentTime: Binding<CGFloat>,
        canSetTime: Bool,
        initialTime: CGFloat,
        finalTime: CGFloat
    )-> some View {
        self.modifier(
            AccessibilitySetCurrentTimeViewModifier(
                currentTime: currentTime,
                canSetTime: canSetTime,
                initialTime: initialTime,
                finalTime: finalTime
            )
        )
        .disabled(!canSetTime)
    }
}

private struct AccessibilitySetCurrentTimeViewModifier: ViewModifier {
    @Binding var currentTime: CGFloat
    let canSetTime: Bool
    let initialTime: CGFloat
    let finalTime: CGFloat

    func body(content: Content) -> some View {
        content.accessibilityAdjustableAction { direction in
            guard canSetTime else {
                return
            }
            let dt = finalTime - initialTime
            let increment = dt / 10
            let sign: CGFloat = direction == .increment ? 1 : -1
            let newValue = currentTime + (sign * increment)
            currentTime = min(finalTime, max(newValue, initialTime))
        }
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
