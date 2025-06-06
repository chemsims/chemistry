//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct PHScaleGeometry {
    init(
        width: CGFloat,
        height: CGFloat,
        tickCount: Int,
        topLeftTickValue: CGFloat,
        topRightTickValue: CGFloat
    ) {
        self.width = width
        self.height = height
        self.tickCount = tickCount
        self.topLeftTickValue = topLeftTickValue
        self.topRightTickValue = topRightTickValue
    }

    let width: CGFloat
    let height: CGFloat
    let tickCount: Int
    let topLeftTickValue: CGFloat
    let topRightTickValue: CGFloat

    var barSize: CGSize {
        CGSize(
            width: 0.84 * width,
            height: 0.47 * height
        )
    }

    var barVerticalSpacing: CGFloat {
        (height - barSize.height) / 2
    }

    var barHorizontalSpacing: CGFloat {
        (width - barSize.width) / 2
    }
}

// MARK: Label geometry
extension PHScaleGeometry {

    var labelsFontSize: CGFloat {
        1.5 * tickLabelFontSize
    }

    var sideLabelsHeight: CGFloat {
        4 * tickHeight
    }
}

// MARK: Tick geometry
extension PHScaleGeometry {
    var tickXSpacing: CGFloat {
        barSize.width / CGFloat(tickCount + 1)
    }

    var tickLabelWidth: CGFloat {
        0.8 * tickXSpacing
    }

    var tickLabelFontSize: CGFloat {
        0.021 * barSize.width
    }

    var tickHeight: CGFloat {
        0.07 * barSize.height
    }
}

// MARK: Indicator geometry
extension PHScaleGeometry {
    var indicatorSize: CGSize {
        CGSize(
            width: 0.18 * width,
            height: barVerticalSpacing
        )
    }

    var indicatorFontSize: CGFloat {
        0.9 * labelsFontSize
    }

    var topIndicatorAxis: LinearAxis<CGFloat> {
        indicatorAxis(
            leftValue: topLeftTickValue,
            rightValue: topRightTickValue
        )
    }

    var bottomIndicatorAxis: LinearAxis<CGFloat> {
        indicatorAxis(
            leftValue: topRightTickValue,
            rightValue: topLeftTickValue
        )
    }

    private func indicatorAxis(
        leftValue: CGFloat,
        rightValue: CGFloat
    ) -> LinearAxis<CGFloat> {
        LinearAxis(
            minValuePosition: barHorizontalSpacing + tickXSpacing,
            maxValuePosition: width - barHorizontalSpacing - tickXSpacing,
            minValue: leftValue,
            maxValue: rightValue
        )
    }
}
