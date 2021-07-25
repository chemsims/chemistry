//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct ReactionRateChartLayoutSettings {
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

    var sliderHandleWidth: CGFloat {
        ReactionRateChartLayoutSettings.sliderHandleWidthFactor * chartSize
    }

    var sliderMaxValuePadding: CGFloat {
        0.28 * chartSize
    }

    var sliderSettings: SliderGeometrySettings {
        SliderGeometrySettings(handleWidth: sliderHandleWidth)
    }

    var indicatorSettings: SliderGeometrySettings {
        SliderGeometrySettings(
            handleWidth: indicatorWidth,
            handleThickness: indicatorThickness,
            handleCornerRadius: 0,
            barThickness: 0
        )
    }

    var yLabelWidth: CGFloat {
        ReactionRateChartLayoutSettings.yLabelWidthFactor * chartSize
    }
    var xLabelHeight: CGFloat {
        ReactionRateChartLayoutSettings.xLabelHeightFactor * chartSize
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
        ReactionRateChartLayoutSettings.chartHStackFactor * chartSize
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

    /// Minimum spacing between two inputs
    var inputSpacing: CGFloat {
        1.1 * sliderSettings.handleThickness
    }

    static let chartHStackFactor: CGFloat = 0.03
    static let sliderHandleWidthFactor: CGFloat = 0.16
    static let yLabelWidthFactor: CGFloat = 0.35

    static let xLabelHeightFactor: CGFloat = 0.1

    static let totalWidthFactor = 1 + (2 * chartHStackFactor) + sliderHandleWidthFactor + yLabelWidthFactor

    static let totalHeightFactor = 1 + (2 * chartHStackFactor) + sliderHandleWidthFactor + xLabelHeightFactor
}

extension ReactionRateChartLayoutSettings {
    var chartAxisShapeSettings: ChartAxisShapeSettings {
        ChartAxisShapeSettings(chartSize: chartSize)
    }
}
