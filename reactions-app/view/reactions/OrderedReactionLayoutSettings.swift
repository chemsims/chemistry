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
        let maxHeight = 0.32 * height
        let maxWidth = 0.25 * width
        let idealWidth = 0.2 * width
        return min(maxHeight, min(maxWidth, idealWidth))
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
    var beakerWidth: CGFloat {
        if let h = horizontalSize, h == .regular, let v = verticalSize, v == .regular {
            return 0.25 * width
        }
        if let h = horizontalSize, h == .regular, let v = verticalSize, v == .compact {
            return 0.2 * width
        }
        return 0.23 * width
    }
    var beakerHeight: CGFloat {
        beakerWidth * BeakerSettings.heightToWidth
    }
    var midChartsLeftPadding: CGFloat {
        chartSize * 0.2
    }
    var chartsTopPadding: CGFloat {
        chartSize * 0.2
    }
    var beakyRightPadding: CGFloat {
        bubbleWidth * 0.2
    }
    var beakyBottomPadding: CGFloat {
        beakyRightPadding * 0.1
    }
    var beakerLeadingPadding: CGFloat {
        1.1 * (menuLeadingPadding + menuSize)
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
        let totalChartsWidth = chartSettings.largeTotalChartWidth + chartSettings.chartSize
        let chartsWithSpacing = totalChartsWidth + (2 * topStackHSpacing)
        return width - beakerWidth - beakerLeadingPadding - chartsWithSpacing - beakerLeadingPadding
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
        0.2 * beakerWidth
    }

    var menuLeadingPadding: CGFloat {
        0.5 * menuSize
    }

    var menuTopPadding: CGFloat {
        0.5 * menuSize
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

}
