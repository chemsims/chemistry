//
// Reactions App
//

import CoreGraphics

struct ICETableElement {
    let initial: CGFloat
    let final: CGFloat

    var change: CGFloat {
        final - initial
    }
}
