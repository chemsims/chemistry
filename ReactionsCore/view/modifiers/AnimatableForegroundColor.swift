//
// Reactions App
//

import SwiftUI

struct AnimatableForegroundColor: AnimatableModifier {

    let rgb: RGBEquation
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content
            .foregroundColor(rgb.getRgb(at: progress).color)
    }
}
