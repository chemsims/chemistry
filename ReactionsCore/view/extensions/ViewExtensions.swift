//
// Reactions App
//

import SwiftUI

extension View {

    // TODO - replace usages of this after updating to Swift 5.5 when
    // possible using compiler flags
    // e.g.
    // Text("Hello")
    //    #if os(iOS)
    //        .font(.title)
    //    #else
    //        .font(.body)
    //    #endif
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

    public func frame(size: CGSize) -> some View {
        self.frame(width: size.width, height: size.height)
    }

    public func foregroundColor(rgb: RGBEquation, progress: CGFloat) -> some View {
        self.modifier(AnimatableForegroundColor(rgb: rgb, progress: progress))
    }
}

