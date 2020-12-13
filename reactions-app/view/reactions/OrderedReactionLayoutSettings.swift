//
// Reactions App
//
  

import SwiftUI

struct OrderedReactionLayoutSettings {
    let geometry: GeometryProxy
    let horizontalSize: UserInterfaceSizeClass?
    let verticalSize: UserInterfaceSizeClass?

    var width: CGFloat {
        geometry.size.width
    }

    var height: CGFloat {
        geometry.size.height
    }

    var bubbleWidth: CGFloat {
        if (vIsRegular && hIsRegular) {
            return 0.25 * width
        }
        return 0.22 * width
    }
    var bubbleHeight: CGFloat {
        if (vIsRegular && hIsRegular) {
            return 1.1 * bubbleWidth
        }
        return 0.8 * bubbleWidth
    }

    var chartSize: CGFloat {
        return topStackUtil.chartSize
    }

    var chartHPadding: CGFloat {
        OrderedReactionLayoutSettings.chartHPaddingFactor * chartSize
    }

    var beakerWidth: CGFloat {
        return topStackUtil.beakerWidth
    }

    var chartSettings: TimeChartGeometrySettings {
        TimeChartGeometrySettings(chartSize: chartSize)
    }

    var topStackHSpacing: CGFloat {
        0.1 * chartSize
    }

    var bubbleFontSize: CGFloat {
        bubbleWidth * 0.08
    }
    var beakyHeight: CGFloat {
        0.7 * bubbleHeight
    }
    var navButtonSize: CGFloat {
        bubbleHeight * 0.2
    }
    var bubbleStemWidth: CGFloat {
        SpeechBubbleSettings.getStemWidth(width: bubbleWidth)
    }
    var beakerHeight: CGFloat {
        beakerWidth * BeakerSettings.heightToWidth
    }

    var midChartsLeftPadding: CGFloat {
        chartSize * 0.2
    }
    var chartsTopPadding: CGFloat {
        0.05 * height
    }
    var beakyRightPadding: CGFloat {
        bubbleWidth * 0.2
    }
    var beakyBottomPadding: CGFloat {
        beakyRightPadding * 0.1
    }
    var beakerLeadingPadding: CGFloat {
        0.5 * menuSize
    }
    var beakyBoxTotalHeight: CGFloat {
        bubbleHeight + navButtonSize + beakyVSpacing + beakyBottomPadding
    }
    var beakyBoxTotalWidth: CGFloat {
        bubbleWidth + (beakyHeight * 0.54) + beakyRightPadding
    }
    var beakyVSpacing: CGFloat {
        return 2
    }

    var availableWidthForTable: CGFloat {
        width -
            menuTotalWidth -
            beakerWidth -
            chartSettings.largeTotalChartWidth -
            chartSize - (4 * chartHPadding) -
            tableTrailingPadding
    }

    var tableTrailingPadding: CGFloat {
        0.05 * width
    }

    var tableCellWidth: CGFloat {
        availableWidthForTable / 3
    }

    var tableCellHeight: CGFloat {
        chartSize / 3
    }

    var tableButtonSize: CGFloat {
        let w = 0.5 * tableCellWidth
        let h = 0.5 * tableCellHeight
        return min(w, h)
    }

    var tableFontSize: CGFloat {
        bubbleFontSize
    }

    var menuSize: CGFloat {
        0.03 * width
    }

    var menuLeadingPadding: CGFloat {
        0.5 * menuSize
    }

    var menuTopPadding: CGFloat {
        0.5 * menuSize
    }

    var menuTotalWidth: CGFloat {
        menuSize + menuLeadingPadding
    }

    private var hIsRegular: Bool {
        if let h = horizontalSize {
            return h == .regular
        }
        return false
    }

    private var vIsRegular: Bool {
        if let v = verticalSize {
            return v == .regular
        }
        return false
    }

    private var topStackUtil: TopStackLayoutUtil {
        TopStackLayoutUtil(
            totalWidth: width - menuTotalWidth,
            totalHeight: (height / 2) - chartsTopPadding
        )
    }

    static let chartHPaddingFactor: CGFloat = 0.05
}

fileprivate struct TopStackLayoutUtil {

    let totalWidth: CGFloat
    let totalHeight: CGFloat

    var beakerWidth: CGFloat {
        min(beakerMaxWidthForHeight, beakerMaxWidth)
    }

    var chartSize: CGFloat {
        min(maxChartSizeForHeight, chartMaxWidth)
    }

    private var beakerMaxWidthForHeight: CGFloat {
        totalHeight / BeakerSettings.heightToWidth
    }

    private var beakerMaxWidth: CGFloat {
        totalWidth / 4
    }

    private var chartMaxWidth: CGFloat {
        let totalWidthForBothCharts = totalWidth / 2
        let wFactor = (TimeChartGeometrySettings.totalWidthFactor + 1) + (4 * OrderedReactionLayoutSettings.chartHPaddingFactor)
        return totalWidthForBothCharts / wFactor
    }

    private var maxChartSizeForHeight: CGFloat {
        let chartToWidth = TimeChartGeometrySettings.totalHeightFactor
        return (totalHeight / chartToWidth)
    }

}
