//
// Reactions App
//
  

import CoreGraphics

struct EquationGeometrySettings {
    let scale: CGFloat

    var boxSize: CGFloat {
        45 * scale
    }
    var boxPadding: CGFloat {
        10 * scale
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
    var subscriptFontSize: CGFloat {
        fontSize * 0.6
    }
    var subscriptBaselineOffset: CGFloat {
        fontSize * -0.4
    }
}
