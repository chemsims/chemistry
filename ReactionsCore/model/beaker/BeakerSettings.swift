//
// Reactions App
//

import CoreGraphics

public struct BeakerSettings {

    public static let heightToWidth: CGFloat = 1.1

    public let width: CGFloat
    let hasLip: Bool

    public init(width: CGFloat, hasLip: Bool) {
        self.width = width
        self.hasLip = hasLip
    }

    public var lipRadius: CGFloat {
        hasLip ? width * 0.03 : 0
    }

    public var lipWidthLeft: CGFloat {
        hasLip ? width * 0.01 : 0
    }

    public var mediumBeakerRightLipWidth: CGFloat {
        lipWidthLeft * 9
    }

    public var smallBeakerRightLipWidth: CGFloat {
        mediumBeakerRightLipWidth
    }

    public var outerBottomCornerRadius: CGFloat {
        width * 0.1
    }

    public var mediumBeakerRightGap: CGFloat {
        hasLip ? lipWidthLeft * 5 : 0.15 * width
    }

    public var smallBeakerRightGap: CGFloat {
        hasLip ? 2 * mediumBeakerRightGap : 1.5 * mediumBeakerRightGap
    }

    public var innerLeftBottomCornerRadius: CGFloat {
        outerBottomCornerRadius
    }

    public var mediumBeakerRightCornerRadius: CGFloat {
        outerBottomCornerRadius * 1.5
    }

    public var smallBeakerRightCornerRadius: CGFloat {
        mediumBeakerRightCornerRadius * 1.2
    }

    public var innerBeakersBottomGap: CGFloat {
        width * 0.055
    }

    public var numTicks: Int {
        13
    }

    public var ticksBottomGap: CGFloat {
        innerBeakersBottomGap * 1.5
    }

    public var ticksMinorWidth: CGFloat {
        width * 0.075
    }

    public var ticksMajorWidth: CGFloat {
        ticksMinorWidth * 2
    }

    public var ticksTopGap: CGFloat {
        lipRadius * 4
    }

    public var ticksRightGap: CGFloat {
        lipRadius + mediumBeakerRightGap + mediumBeakerRightLipWidth
    }

    public var innerBeakerWidth: CGFloat {
        width - (2 * lipRadius) - (2 * lipWidthLeft)
    }
}
