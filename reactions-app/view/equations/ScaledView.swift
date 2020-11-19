//
// Reactions App
//
  

import SwiftUI

struct ScaledView<Content: View>: View {
    let naturalWidth: CGFloat
    let naturalHeight: CGFloat
    let maxWidth: CGFloat?
    let maxHeight: CGFloat?
    let content: () -> Content

    var body: some View {
        content()
            .scaleEffect(x: scale, y: scale)
    }

    private var scale: CGFloat {
        let xScale = maxWidth.map { w in w / naturalWidth } ?? 1
        let yScale = maxHeight.map { w in w / naturalHeight } ?? 1
        return min(xScale, yScale)
    }

}
