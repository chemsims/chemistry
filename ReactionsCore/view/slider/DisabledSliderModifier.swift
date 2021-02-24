//
// Reactions App
//


import SwiftUI

public struct DisabledSliderModifier: ViewModifier {
    private let disabled: Bool

    public init(disabled: Bool) {
        self.disabled = disabled
    }

    public func body(content: Content) -> some View {
        content
            .disabled(disabled)
            .compositingGroup()
            .colorMultiply(disabled ? .gray : .white)
            .opacity(disabled ? 0.3 : 1)
    }
}
