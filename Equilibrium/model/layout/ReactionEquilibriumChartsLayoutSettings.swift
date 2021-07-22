//
// Reactions App
//

import ReactionsCore
import CoreGraphics

struct ReactionEquilibriumChartsLayoutSettings {

    let size: CGFloat
    let maxYAxisValue: CGFloat

    var headRadius: CGFloat {
        0.018 * size
    }

    var layout: TimeChartLayoutSettings {
        TimeChartLayoutSettings(
            xAxis: AxisPositionCalculations<CGFloat>(
                minValuePosition: 0,
                maxValuePosition: size,
                minValue: 0,
                maxValue: AqueousReactionSettings.forwardReactionTime
            ),
            yAxis: AxisPositionCalculations<CGFloat>(
                minValuePosition: size,
                maxValuePosition: 0.2 * size,
                minValue: 0,
                maxValue: maxYAxisValue
            ),
            haloRadius: 2 * headRadius,
            lineWidth: 0.3 * headRadius
        )
    }

    var axisShapeSettings: ChartAxisShapeSettings {
        ChartAxisShapeSettings(chartSize: size)
    }

    var axisLabelFontSize: CGFloat {
        Self.fontSizeToChartWidth * size
    }

    static let fontSizeToChartWidth: CGFloat = 0.06
}

extension ReactionEquilibriumChartsLayoutSettings {
    var totalChartWidth: CGFloat {
        size + (2 * (yAxisWidthLabelWidth + axisLabelGapFromAxis))
    }

    var totalChartHeight: CGFloat {
        size + axisLabelGapFromAxis + xAxisLabelHeight
    }
}

extension ReactionEquilibriumChartsLayoutSettings {
    var legendCircleSize: CGFloat {
        0.1 * size
    }

    var legendSpacing: CGFloat {
        0.8 * legendCircleSize
    }

    var legendFontSize: CGFloat {
        0.6 * legendCircleSize
    }

    var legendPadding: CGFloat {
        0.35 * legendCircleSize
    }
}

extension ReactionEquilibriumChartsLayoutSettings {
    var yAxisWidthLabelWidth: CGFloat {
        0.1 * size
    }

    var axisLabelGapFromAxis: CGFloat {
        headRadius
    }

    var xAxisLabelHeight: CGFloat {
        0.1 * size
    }
}
