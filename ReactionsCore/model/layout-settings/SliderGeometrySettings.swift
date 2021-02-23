//
// Reactions App
//


import CoreGraphics

public struct SliderGeometrySettings {

    public let handleWidth: CGFloat

    public init(handleWidth: CGFloat) {
        self.handleWidth = handleWidth
    }

    var handleThickness: CGFloat {
        0.5 * handleWidth
    }

    var handleCornerRadius: CGFloat {
        0.25 * handleThickness
    }

    var barThickness: CGFloat {
        0.094 * handleWidth
    }
}
