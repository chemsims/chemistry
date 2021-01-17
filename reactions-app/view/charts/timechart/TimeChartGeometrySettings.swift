//
// Reactions App
//


import CoreGraphics

struct TimeChartGeometrySettings {
    let chartSize: CGFloat

    init(
        chartSize: CGFloat,
        minConcentration: CGFloat = ReactionSettings.Axis.minC,
        maxConcentration: CGFloat = ReactionSettings.Axis.maxC,
        minTime: CGFloat = ReactionSettings.Axis.minT,
        maxTime: CGFloat = ReactionSettings.Axis.maxT,
        includeAxisPadding: Bool = true
    ) {
        self.chartSize = chartSize
        self.minConcentration = minConcentration
        self.maxConcentration = maxConcentration
        self.minTime = minTime
        self.maxTime = maxTime
        self.includeAxisPadding = includeAxisPadding
    }

    // Min/max of the axis
    let minConcentration: CGFloat
    let maxConcentration: CGFloat
    let minTime: CGFloat
    let maxTime: CGFloat

    private let includeAxisPadding: Bool

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
        TimeChartGeometrySettings.sliderHandleWidthFactor * chartSize
    }
    var sliderHandleThickness: CGFloat {
        0.16 * chartSize
    }
    var sliderMaxValuePadding: CGFloat {
        0.28 * chartSize
    }
    var yLabelWidth: CGFloat {
        TimeChartGeometrySettings.yLabelWidthFactor * chartSize
    }
    var xLabelHeight: CGFloat {
        TimeChartGeometrySettings.xLabelHeightFactor * chartSize
    }
    var handleThickness: CGFloat {
        0.08 * chartSize
    }
    var handleCornerRadius: CGFloat {
        handleThickness * 0.25
    }
    var barThickness: CGFloat {
        0.015 * chartSize
    }
    var labelFontSize: CGFloat {
        0.1 * chartSize
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
    var indicatorThickness: CGFloat {
        max(1, 0.015 * chartSize)
    }
    var indicatorWidth: CGFloat {
        sliderHandleWidth * 0.75
    }
    var timePlotLineWidth: CGFloat {
        chartSize / 180
    }

    var chartHStackSpacing: CGFloat {
        TimeChartGeometrySettings.chartHStackFactor * chartSize
    }
    var chartVStackSpacing: CGFloat {
        chartHStackSpacing
    }

    var largeTotalChartWidth: CGFloat {
        chartSize + (2 * chartHStackSpacing) + sliderHandleWidth + yLabelWidth
    }

    var yAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: chartSize,
            maxValuePosition: includeAxisPadding ? sliderMaxValuePadding : 0,
            minValue: minConcentration,
            maxValue: maxConcentration
        )
    }

    var xAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: 0,
            maxValuePosition: includeAxisPadding ? chartSize - sliderMaxValuePadding : chartSize,
            minValue: minTime,
            maxValue: maxTime
        )
    }

    static let chartHStackFactor: CGFloat = 0.03
    static let sliderHandleWidthFactor: CGFloat = 0.16
    static let yLabelWidthFactor: CGFloat = 0.35

    static let xLabelHeightFactor: CGFloat = 0.1

    static let totalWidthFactor = 1 + (2 * chartHStackFactor) + sliderHandleWidthFactor + yLabelWidthFactor

    static let totalHeightFactor = 1 + (2 * chartHStackFactor) + sliderHandleWidthFactor + xLabelHeightFactor
}
