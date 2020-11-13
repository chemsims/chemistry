//
// Reactions App
//


import CoreGraphics

struct TimeChartGeometrySettings {
    let chartSize: CGFloat

    let minConcentration: CGFloat
    let maxConcentration: CGFloat
    let minTime: CGFloat
    let maxTime: CGFloat

    let verticalTicks = 10
    let horizontalTicks = 10
    var tickSize: CGFloat {
        0.04 * chartSize
    }
    var gapFromMaxTickToChart: CGFloat {
        0.24 * chartSize
    }
    var sliderHandleWidth: CGFloat {
        0.16 * chartSize
    }
    var sliderHandleThickness: CGFloat {
        0.16 * chartSize
    }
    var sliderMinValuePadding: CGFloat {
        0.1 * chartSize
    }
    var sliderMaxValuePadding: CGFloat {
        0.28 * chartSize
    }
    var yLabelWidth: CGFloat {
        0.32 * chartSize
    }
    var handleThickness: CGFloat {
        0.08 * chartSize
    }
    var handleCornerRadius: CGFloat {
        handleThickness * 0.25
    }
    var labelFontSize: CGFloat {
        0.06 * chartSize
    }
    var chartHeadPrimarySize: CGFloat {
        0.02 * chartSize
    }
    var chartHeadPrimaryHaloSize: CGFloat {
        3 * chartHeadPrimarySize
    }

    var yAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: chartSize - sliderMinValuePadding,
            maxValuePosition: sliderMaxValuePadding,
            minValue: minConcentration,
            maxValue: maxConcentration
        )
    }

    var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: sliderMinValuePadding,
            maxValuePosition: chartSize - sliderMaxValuePadding,
            minValue: minTime,
            maxValue: maxTime
        )
    }
}
