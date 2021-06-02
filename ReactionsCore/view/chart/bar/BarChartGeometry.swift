//
// Reactions App
//

import CoreGraphics

public struct BarChartGeometry {

    public init(
        chartWidth: CGFloat,
        minYValue: CGFloat,
        maxYValue: CGFloat,
        barWidthFraction: CGFloat = 0.15,
        fontSizeFraction: CGFloat = 0.1
    ) {
        self.chartWidth = chartWidth
        self.minYValue = minYValue
        self.maxYValue = maxYValue
        self.barWidthFraction = barWidthFraction
        self.fontSizeFraction = fontSizeFraction
    }

    let chartWidth: CGFloat
    let minYValue: CGFloat
    let maxYValue: CGFloat
    let barWidthFraction: CGFloat
    let fontSizeFraction: CGFloat

    let ticks = 10

    public var totalHeight: CGFloat {
        chartWidth + chartToAxisSpacing + totalAxisHeight
    }

    var yAxisTickSize: CGFloat {
        0.05 * chartWidth
    }

    var yAxis: AxisPositionCalculations<CGFloat> {
        AxisPositionCalculations(
            minValuePosition: chartWidth - barMinHeight,
            maxValuePosition: chartWidth - maxBarHeight,
            minValue: minYValue,
            maxValue: maxYValue
        )
    }

    var barWidth: CGFloat {
        barWidthFraction * chartWidth
    }

    var tickDy: CGFloat {
        chartWidth / CGFloat(ticks + 1)
    }

    var labelDiameter: CGFloat {
        0.67 * barWidth
    }

    public var chartToAxisSpacing: CGFloat {
        0.03 * chartWidth
    }

    var labelToCircleSpacing: CGFloat {
        0.2 * labelDiameter
    }

    public var labelFontSize: CGFloat {
        fontSizeFraction * chartWidth
    }

    var labelTextHeight: CGFloat {
        1.1 * labelFontSize
    }

    public var totalAxisHeight: CGFloat {
        labelDiameter + labelToCircleSpacing + labelTextHeight
    }

    private var barMinHeight: CGFloat {
        tickDy / 5
    }

    private var maxBarHeight: CGFloat {
        0.75 * chartWidth
    }
}
