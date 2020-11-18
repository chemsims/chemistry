//
// Reactions App
//
  

import CoreGraphics

struct ZeroOrderEquationGeometry {
    let maxWidth: CGFloat
    let maxHeight: CGFloat

    var width: CGFloat {
        return maxWidth
    }

    var rateWidth: CGFloat {
        width * 0.1
    }
    var equalsWidth: CGFloat {
        width * 0.03
    }

    var fractionBoxHeight: CGFloat {
        let maxBoxHeight = (maxHeight - 1) / 2
        return min(boxWidth * 0.75, maxBoxHeight)
    }

    var boxWidth: CGFloat {
        width * 0.12
    }
    var boxHeight: CGFloat {
        boxWidth * 0.75
    }
    var negativeWidth: CGFloat {
        equalsWidth
    }
    var boxPadding: CGFloat {
        boxWidth * 0.3
    }
    var fraction1DividerWidth: CGFloat {
        width * 0.06
    }
    var fontSize: CGFloat {
        width * 0.04
    }
    var fraction2DividerWidth: CGFloat {
        width * 0.25
    }
    var parenWidth: CGFloat {
        equalsWidth
    }
    var subscriptFontSize: CGFloat {
        fontSize * 0.6
    }
    var subscriptBaselineOffset: CGFloat {
        fontSize * -0.4
    }

    var halfTimeHeight: CGFloat {
        min(boxWidth * 0.8, maxHeight)
    }

    var halfTimeWidth: CGFloat {
        boxWidth
    }
}
