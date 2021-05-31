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
        topTickMinValue: CGFloat,
        topTickMaxValue: CGFloat
    ) {
        self.width = width
        self.height = height
        self.tickCount = tickCount
        self.topTickMinValue = topTickMinValue
        self.topTickMaxValue = topTickMaxValue
    }

    let width: CGFloat
    let height: CGFloat
    let tickCount: Int
    let topTickMinValue: CGFloat
    let topTickMaxValue: CGFloat

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
            width: 0.167 * width,
            height: barVerticalSpacing
        )
    }

    var indicatorFontSize: CGFloat {
        0.9 * labelsFontSize
    }

    var topIndicatorAxis: AxisPositionCalculations<CGFloat> {
        indicatorAxis(minValue: topTickMinValue, maxValue: topTickMaxValue)
    }

    var bottomIndicatorAxis: AxisPositionCalculations<CGFloat> {
        indicatorAxis(minValue: topTickMaxValue, maxValue: topTickMinValue)
    }

    private func indicatorAxis(
        minValue: CGFloat,
        maxValue: CGFloat
    ) -> AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: barHorizontalSpacing + tickXSpacing,
            maxValuePosition: width - barHorizontalSpacing - tickXSpacing,
            minValue: minValue,
            maxValue: maxValue
        )
    }
}
