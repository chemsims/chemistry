//
// Reactions App
//


import SwiftUI
import ReactionsCore


struct TimeChartDataline {
    let equation: Equation
    let headColor: Color
    let haloColor: Color?
    let headRadius: CGFloat
    let haloSize: CGFloat
}

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

struct TimeChartMultiPlot: View {

    let settings: TimeChartLayoutSettings
    let data: [TimeChartDataline]

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat

    let filledBarColor: Color
    let headColor: Color
    let headRadius: CGFloat
    let haloColor: Color?
    let canSetCurrentTime: Bool

    let highlightLhs: Bool
    let highlightRhs: Bool

    var body: some View {
        ZStack {
            ForEach(0..<data.count, id: \.self) { i in
                ChartPlotWithHead(
                    data: data[i],
                    settings: settings,
                    initialTime: initialTime,
                    currentTime: $currentTime,
                    finalTime: finalTime,
                    filledBarColor: filledBarColor,
                    canSetCurrentTime: canSetCurrentTime,
                    highlightLhs: highlightLhs,
                    highlightRhs: highlightRhs
                )
            }
        }
    }
}

struct ChartPlotWithHead: View {

    let data: TimeChartDataline
    let settings: TimeChartLayoutSettings

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat

    let filledBarColor: Color
    let canSetCurrentTime: Bool

    let highlightLhs: Bool
    let highlightRhs: Bool

    var body: some View {
        ZStack {
            dataLine(time: finalTime, color: filledBarColor)
            dataLine(time: currentTime, color: data.headColor)
            if highlightLhs {
                highlightLine(startTime: initialTime, endTime: (initialTime + finalTime) / 2)
            }
            if highlightRhs {
                highlightLine(startTime: (initialTime + finalTime) / 2, endTime: finalTime)
            }

            if data.haloColor != nil {
                head(
                    radius: settings.haloRadius,
                    color: data.haloColor!
                )
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { gesture in
                    guard canSetCurrentTime else {
                        return
                    }
                    let xLocation = gesture.location.x
                    let newTime = settings.xAxis.getValue(at: xLocation)
                    currentTime = max(initialTime, min(finalTime, newTime))
                })
            }
            head(
                radius: data.headRadius,
                color: data.headColor
            )
        }
    }

    private func head(
        radius: CGFloat,
        color: Color
    ) -> some View {
        ChartIndicatorHead(
            radius: radius,
            equation: data.equation,
            yAxis: settings.yAxis,
            xAxis: settings.xAxis,
            x: currentTime
        )
        .fill()
        .foregroundColor(color)
    }

    private func dataLine(
        time: CGFloat,
        color: Color
    ) -> some View {
        line(
            startTime: initialTime,
            time: time,
            color: color,
            lineWidth: settings.lineWidth
        )
    }

    private func highlightLine(
        startTime: CGFloat,
        endTime: CGFloat
    ) -> some View {
        line(
            startTime: startTime,
            time: endTime,
            color: data.headColor,
            lineWidth: 2.5 * settings.lineWidth
        )
    }

    private func line(
        startTime: CGFloat,
        time: CGFloat,
        color: Color,
        lineWidth: CGFloat
    ) -> some View {
        ChartLine(
            equation: data.equation,
            yAxis: settings.yAxis,
            xAxis: settings.xAxis,
            startX: startTime,
            endX: time
        )
        .stroke(lineWidth: lineWidth)
        .foregroundColor(color)
    }
}
