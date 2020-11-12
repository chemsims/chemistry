//
// Reactions App
//
  

import CoreGraphics

struct EquationGeometrySettings {
    let scale: CGFloat

    var boxSize: CGFloat {
        35 * scale
    }
    var boxPadding: CGFloat {
        6 * scale
    }
    var negativeWidth: CGFloat {
        10 * scale
    }
    var parenWidth: CGFloat {
        7 * scale
    }
    var fontSize: CGFloat {
        15 * scale
    }
}
