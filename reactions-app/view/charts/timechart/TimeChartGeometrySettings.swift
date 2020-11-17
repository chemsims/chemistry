//
// Reactions App
//


import CoreGraphics

struct TimeChartGeometrySettings {
    let chartSize: CGFloat

    init(
        chartSize: CGFloat,
        minConcentration: CGFloat = ReactionSettings.minConcentration,
        maxConcentration: CGFloat = ReactionSettings.maxConcentration
    ) {
        self.chartSize = chartSize
        self.minConcentration = minConcentration
        self.maxConcentration = maxConcentration
    }

    // Min/max of the axis
    let minConcentration: CGFloat
    let maxConcentration: CGFloat
    let minTime: CGFloat = ReactionSettings.minTime
    let maxTime: CGFloat = ReactionSettings.maxTime

    let minFinalConcentration: CGFloat = ReactionSettings.minFinalConcentration

    let minFinalTime: CGFloat = ReactionSettings.minFinalTime

    /// minimum spacing between the edge of a slider
    var sliderMinSpacing: CGFloat {
        sliderHandleThickness * 0.1
    }

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
    var barThickness: CGFloat {
        3
    }
    var labelFontSize: CGFloat {
        0.06 * chartSize
    }
    var chartHeadPrimarySize: CGFloat {
        0.02 * chartSize
    }
    var chartHeadSecondarySize: CGFloat {
        chartHeadPrimarySize * 0.5
    }
    var chartHeadPrimaryHaloSize: CGFloat {
        3 * chartHeadPrimarySize
    }

    var yAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: chartSize,
            maxValuePosition: sliderMaxValuePadding,
            minValue: minConcentration,
            maxValue: maxConcentration
        )
    }

    var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0,
            maxValuePosition: chartSize - sliderMaxValuePadding,
            minValue: minTime,
            maxValue: maxTime
        )
    }
}
