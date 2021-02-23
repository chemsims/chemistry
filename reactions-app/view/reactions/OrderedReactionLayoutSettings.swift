//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct OrderedReactionLayoutSettings {
    let geometry: GeometryProxy
    let horizontalSize: UserInterfaceSizeClass?
    let verticalSize: UserInterfaceSizeClass?

    // MARK: Screen Size
    var width: CGFloat {
        geometry.size.width
    }
    var height: CGFloat {
        geometry.size.height
    }
    var topPadding: CGFloat {
        0.05 * height
    }
    var topStackSize: CGFloat {
        height / 2
    }

    // MARK: Beaker Size
    var beakerWidth: CGFloat {
        return topStackUtil.beakerWidth
    }
    var beakerHeight: CGFloat {
        beakerWidth * BeakerSettings.heightToWidth
    }

    // MARK: Chart size
    var chartSize: CGFloat {
        return topStackUtil.chartSize
    }
    var chartHPadding: CGFloat {
        OrderedReactionLayoutSettings.chartHPaddingFactor * chartSize
    }
    var chartSettings: ReactionRateChartLayoutSettings {
        ReactionRateChartLayoutSettings(chartSize: chartSize)
    }
    var secondaryChartPadding: CGFloat {
        0.1 * chartSize
    }

    // MARK: Equation size
    var equationPadding: CGFloat {
        0.05 * chartSize
    }

    // MARK: Beaky & bubble size
    var beakyTotalHeight: CGFloat {
        height - topStackSize - beakyBottomPadding
    }
    var beakyRightPadding: CGFloat {
        0.01 * width
    }
    var bubbleHeight: CGFloat {
        0.8 * beakyTotalHeight
    }
    var bubbleWidth: CGFloat {
        if vIsRegular && hIsRegular {
            return 0.3 * width
        }
        return 0.3 * width
    }
    var bubbleFontSize: CGFloat {
        0.06 * bubbleWidth
    }
    var beakyHeight: CGFloat {
        0.4 * bubbleWidth
    }
    var navButtonSize: CGFloat {
        bubbleHeight * 0.2
    }
    var bubbleStemWidth: CGFloat {
        SpeechBubbleSettings.getStemWidth(width: bubbleWidth)
    }
    var beakyBottomPadding: CGFloat {
        beakyRightPadding
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

    // MARK: Table size
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

    // MARK: Menu size
    var menuSize: CGFloat {
        0.03 * width
    }

    var menuHPadding: CGFloat {
        0.5 * menuSize
    }

    var menuTopPadding: CGFloat {
        0.5 * menuSize
    }

    var menuTotalWidth: CGFloat {
        menuSize + (2 * menuHPadding)
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
            totalHeight: topStackSize - topPadding
        )
    }

    static let chartHPaddingFactor: CGFloat = 0.05
}

extension OrderedReactionLayoutSettings {
    var beakyGeometrySettings: BeakyGeometrySettings {
        BeakyGeometrySettings(
            beakyVSpacing: beakyVSpacing,
            bubbleWidth: bubbleWidth,
            bubbleHeight: bubbleHeight,
            beakyHeight: beakyHeight,
            bubbleFontSize: bubbleFontSize,
            navButtonSize: navButtonSize,
            bubbleStemWidth: bubbleStemWidth
        )
    }
}

private struct TopStackLayoutUtil {

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
        let wFactor = (ReactionRateChartLayoutSettings.totalWidthFactor + 1) + (4 * OrderedReactionLayoutSettings.chartHPaddingFactor)
        return totalWidthForBothCharts / wFactor
    }

    private var maxChartSizeForHeight: CGFloat {
        let chartToWidth = ReactionRateChartLayoutSettings.totalHeightFactor
        return (totalHeight / chartToWidth)
    }

}
