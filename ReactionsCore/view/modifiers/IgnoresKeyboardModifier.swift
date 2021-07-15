//
// Reactions App
//

import SwiftUI

public struct IgnoresKeyboardModifier: ViewModifier {

    public init() { }

    public func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content
                .ignoresSafeArea(.keyboard, edges: .all)
        } else {
            content
        }
    }
}

extension View {
    public func ignoresKeyboardSafeArea() -> some View {
        self.modifier(IgnoresKeyboardModifier())
    }
}
