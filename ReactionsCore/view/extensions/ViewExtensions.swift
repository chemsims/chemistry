//
// Reactions App
//

import SwiftUI

extension View {
    @ViewBuilder
    public func modifyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }

    public func frame(square size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }

    public func foregroundColor(rgb: RGBEquation, progress: CGFloat) -> some View {
        self.modifier(AnimatableForegroundColor(rgb: rgb, progress: progress))
    }
}

