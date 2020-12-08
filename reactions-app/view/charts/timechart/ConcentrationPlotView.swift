//
// Reactions App
//
  

import SwiftUI

struct ConcentrationPlotView: View {

    let settings: TimeChartGeometrySettings
    let concentrationA: ConcentrationEquation
    let concentrationB: ConcentrationEquation?

    let initialConcentration: CGFloat
    let finalConcentration: CGFloat

    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat
    let canSetCurrentTime: Bool

    let includeAxis: Bool

    init(
        settings: TimeChartGeometrySettings,
        concentrationA: ConcentrationEquation,
        concentrationB: ConcentrationEquation?,
        initialConcentration: CGFloat,
        finalConcentration: CGFloat,
        initialTime: CGFloat,
        currentTime: Binding<CGFloat>,
        finalTime: CGFloat,
        canSetCurrentTime: Bool,
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
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)

            if (includeAxis) {
                verticalIndicator(at: initialTime)
                verticalIndicator(at: finalTime)
                horizontalIndicator(at: concentrationA.getConcentration(at: initialTime))
                horizontalIndicator(at: concentrationA.getConcentration(at: finalTime))
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
                    canSetCurrentTime: canSetCurrentTime
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
                canSetCurrentTime: canSetCurrentTime
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

}

struct ChartPlotWithHead: View {

    let settings: TimeChartGeometrySettings
    let equation: ConcentrationEquation
    let initialTime: CGFloat
    @Binding var currentTime: CGFloat
    let finalTime: CGFloat

    let filledBarColor: Color
    let headColor: Color
    let headRadius: CGFloat
    let haloColor: Color?
    let canSetCurrentTime: Bool

    var body: some View {
        ZStack {
            line(time: finalTime, color: filledBarColor)
            line(time: currentTime, color: headColor)
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
        ConcentrationEquationHead(
            radius: radius,
            equation: equation,
            yAxis: settings.yAxis,
            xAxis: settings.xAxis,
            time: currentTime
        )
        .fill()
        .foregroundColor(color)
    }

    private func line(
        time: CGFloat,
        color: Color
    ) -> some View {
        ConcentrationEquationShape(
            equation: equation,
            yAxis: settings.yAxis,
            xAxis: settings.xAxis,
            initialTime: initialTime,
            finalTime: time
        )
        .stroke(lineWidth: settings.timePlotLineWidth)
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
            currentTime: .constant(0.8),
            finalTime: 10,
            canSetCurrentTime: true
        )
    }

    static var equation = LinearConcentration(t1: 0, c1: 0.8, t2: 10, c2: 0.2)
    static var equation2 = LinearConcentration(t1: 0, c1: 0.2, t2: 10, c2: 0.8)
}
