//
// Reactions App
//
  

import SwiftUI

struct ConcentrationPlotView: View {

    let settings: TimeChartGeometrySettings
    let concentrationA: Equation
    let concentrationB: Equation?

    let initialConcentration: CGFloat
    let finalConcentration: CGFloat

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat
    let canSetCurrentTime: Bool

    let includeAxis: Bool

    let highlightChart: Bool
    let highlightLhsCurve: Bool
    let highlightRhsCurve: Bool

    init(
        settings: TimeChartGeometrySettings,
        concentrationA: Equation,
        concentrationB: Equation?,
        initialConcentration: CGFloat,
        finalConcentration: CGFloat,
        initialTime: CGFloat,
        currentTime: Binding<CGFloat>,
        finalTime: CGFloat,
        canSetCurrentTime: Bool,
        highlightChart: Bool,
        highlightLhsCurve: Bool,
        highlightRhsCurve: Bool,
        includeAxis: Bool = true
    ) {
        self.settings = settings
        self.concentrationA = concentrationA
        self.concentrationB = concentrationB
        self.initialConcentration = initialConcentration
        self.finalConcentration = finalConcentration
        self.initialTime = initialTime
        self._currentTime = currentTime
        self.finalTime = finalTime
        self.canSetCurrentTime = canSetCurrentTime
        self.includeAxis = includeAxis
        self.highlightChart = highlightChart
        self.highlightLhsCurve = highlightLhsCurve
        self.highlightRhsCurve = highlightRhsCurve
    }

    var body: some View {
        ZStack {
            if (highlightChart) {
                Rectangle()
                    .fill(Color.white)
            }
            if (highlightLhsCurve) {
                rectangleHighlight(t1: initialTime, t2: (initialTime + finalTime) / 2)
            }
            if (highlightRhsCurve) {
                rectangleHighlight(t1: (initialTime + finalTime) / 2, t2: finalTime)
            }


            if (includeAxis) {
                verticalIndicator(at: initialTime)
                verticalIndicator(at: finalTime)
                horizontalIndicator(at: concentrationA.getY(at: initialTime))
                horizontalIndicator(at: concentrationA.getY(at: finalTime))
            }

            if (includeAxis) {
                ChartAxisShape(
                    verticalTicks: settings.verticalTicks,
                    horizontalTicks: settings.horizontalTicks,
                    tickSize: settings.tickSize,
                    gapToTop: settings.gapFromMaxTickToChart,
                    gapToSide: settings.gapFromMaxTickToChart
                )
                .stroke()
            }

            if (concentrationB != nil) {
                ChartPlotWithHead(
                    settings: settings,
                    equation: concentrationB!,
                    initialTime: initialTime,
                    currentTime: .constant(currentTime),
                    finalTime: finalTime,
                    filledBarColor: Styling.timeAxisCompleteBar,
                    headColor: Styling.moleculeB,
                    headRadius: settings.chartHeadSecondarySize,
                    haloColor: nil,
                    canSetCurrentTime: canSetCurrentTime,
                    highlightLhs: false,
                    highlightRhs: false
                )
            }

            ChartPlotWithHead(
                settings: settings,
                equation: concentrationA,
                initialTime: initialTime,
                currentTime: $currentTime,
                finalTime: finalTime,
                filledBarColor: Styling.timeAxisCompleteBar,
                headColor: Styling.moleculeA,
                headRadius: settings.chartHeadPrimarySize,
                haloColor: Styling.moleculeAChartHeadHalo,
                canSetCurrentTime: canSetCurrentTime,
                highlightLhs: highlightLhsCurve,
                highlightRhs: highlightRhsCurve
            )

        }.frame(width: settings.chartSize, height: settings.chartSize)
    }

    private func verticalIndicator(at time: CGFloat) -> some View {
        Path { p in
            p.move(
                to: CGPoint(
                    x: settings.xAxis.getPosition(at: time),
                    y: 0
                )
            )
            p.addLine(
                to: CGPoint(
                    x: settings.xAxis.getPosition(at: time),
                    y: settings.chartSize
                )
            )
        }
        .stroke(lineWidth: 0.3)
    }

    private func horizontalIndicator(at concentration: CGFloat) -> some View {
        Path { p in
            p.move(
                to: CGPoint(
                    x: 0,
                    y: settings.yAxis.getPosition(at: concentration)
                )
            )
            p.addLine(
                to: CGPoint(
                    x: settings.chartSize,
                    y: settings.yAxis.getPosition(at: concentration)
                )
            )
        }.stroke(lineWidth: 0.3)
    }

    private func rectangleHighlight(
        t1: CGFloat,
        t2: CGFloat
    ) -> some View {
        let equation = concentrationA
        let x1 = settings.xAxis.getPosition(at: t1)
        let x2 = settings.xAxis.getPosition(at: t2)
        let width = x2 - x1
        let midX = (x2 + x1) / 2

        let c1 = equation.getY(at: t1)
        let c2 = equation.getY(at: t2)
        let y1 = settings.yAxis.getPosition(at: c1)
        let y2 = settings.yAxis.getPosition(at: c2)

        let height = abs(y2 - y1)
        let midY = (y1 + y2) / 2

        return Rectangle()
            .foregroundColor(.white)
            .frame(width: width, height: height)
            .position(x: midX, y: midY)
            .zIndex(-1)
    }

}

struct ChartPlotWithHead: View {

    let settings: TimeChartGeometrySettings
    let equation: Equation
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
            dataLine(time: finalTime, color: filledBarColor)
            dataLine(time: currentTime, color: headColor)
            if (highlightLhs) {
                highlightLine(startTime: initialTime, endTime: (initialTime + finalTime) / 2)
            }
            if (highlightRhs) {
                highlightLine(startTime: (initialTime + finalTime) / 2, endTime: finalTime)
            }

            if (haloColor != nil) {
                head(
                    radius: settings.chartHeadPrimaryHaloSize,
                    color: haloColor!
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
                radius: headRadius,
                color: headColor
            )
        }
    }

    private func head(
        radius: CGFloat,
        color: Color
    ) -> some View {
        ChartIndicatorHead(
            radius: radius,
            equation: equation,
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
            lineWidth: settings.timePlotLineWidth
        )
    }

    private func highlightLine(
        startTime: CGFloat,
        endTime: CGFloat
    ) -> some View {
        line(
            startTime: startTime,
            time: endTime,
            color: headColor,
            lineWidth: 2.5 * settings.timePlotLineWidth
        )
    }

    private func line(
        startTime: CGFloat,
        time: CGFloat,
        color: Color,
        lineWidth: CGFloat
    ) -> some View {
        ChartLine(
            equation: equation,
            yAxis: settings.yAxis,
            xAxis: settings.xAxis,
            startX: startTime,
            endX: time
        )
        .stroke(lineWidth: lineWidth)
        .foregroundColor(color)
    }
}

struct TimeChartPlotView_Previews: PreviewProvider {
    static var previews: some View {
        ConcentrationPlotView(
            settings: TimeChartGeometrySettings(
                chartSize: 300
            ),
            concentrationA: equation,
            concentrationB: equation2,
            initialConcentration: 0.8,
            finalConcentration: 0.2,
            initialTime: 0,
            currentTime: .constant(10),
            finalTime: 10,
            canSetCurrentTime: true,
            highlightChart: false,
            highlightLhsCurve: true,
            highlightRhsCurve: false
        )
    }

    static var equation = ZeroOrderConcentration(t1: 0, c1: 0.8, t2: 10, c2: 0.2)
    static var equation2 = ZeroOrderConcentration(t1: 0, c1: 0.2, t2: 10, c2: 0.8)
}
