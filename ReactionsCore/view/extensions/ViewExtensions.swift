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

    @ViewBuilder
    public func modifyIf<T: ViewModifier>(_ condition: Bool, modifier: T) -> some View {
        if condition {
            self
                .modifier(modifier)
        } else {
            self
        }
    }

    public func foregroundColor(rgb: RGBEquation, progress: CGFloat) -> some View {
        self.modifier(AnimatableForegroundColor(rgb: rgb, progress: progress))
    }
}

