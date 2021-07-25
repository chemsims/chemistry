//
// Reactions App
//


import SwiftUI
import ReactionsCore

extension ReactionRateChartLayoutSettings {
    var timeChartLayoutSettings: TimeChartLayoutSettings {
        TimeChartLayoutSettings(
            xAxis: xAxis,
            yAxis: yAxis,
            haloRadius: chartHeadPrimaryHaloSize,
            lineWidth: timePlotLineWidth
        )
    }
}
