//
// Reactions App
//
  

import SwiftUI

struct ConcentrationPlotView: View {

    let settings: TimeChartGeometrySettings
    let concentrationA: ConcentrationEquation
    let concentrationB: ConcentrationEquation

    let initialConcentration: CGFloat
    let finalConcentration: CGFloat

    let initialTime: CGFloat
    let currentTime: CGFloat
    let finalTime: CGFloat

    private let finalColor: Color = Styling.timeAxisCompleteBar
    private let aProgressColor: Color = .orangeAccent
    private let aProgressHalo: Color = Color.orangeAccent.opacity(0.7)

    var body: some View {
        ZStack {

            verticalIndicator(at: initialTime)
            verticalIndicator(at: finalTime)
            horizontalIndicator(at: initialConcentration)
            horizontalIndicator(at: finalConcentration)

            ChartAxisShape(
                verticalTicks: settings.verticalTicks,
                horizontalTicks: settings.horizontalTicks,
                tickSize: settings.tickSize,
                gapToTop: settings.gapFromMaxTickToChart,
                gapToSide: settings.gapFromMaxTickToChart
            )
            .stroke()

            ChartPlotWithHead(
                settings: settings,
                equation: concentrationB,
                initialTime: initialTime,
                currentTime: currentTime,
                finalTime: finalTime,
                filledBarColor: Styling.timeAxisCompleteBar,
                headColor: Color.blue,
                headRadius: settings.chartHeadSecondarySize,
                haloColor: nil
            )

            ChartPlotWithHead(
                settings: settings,
                equation: concentrationA,
                initialTime: initialTime,
                currentTime: currentTime,
                finalTime: finalTime,
                filledBarColor: Styling.timeAxisCompleteBar,
                headColor: Styling.moleculeAChartHead,
                headRadius: settings.chartHeadPrimarySize,
                haloColor: Styling.moleculeAChartHeadHalo
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
    let currentTime: CGFloat
    let finalTime: CGFloat

    let filledBarColor: Color
    let headColor: Color
    let headRadius: CGFloat
    let haloColor: Color?


    var body: some View {
        ZStack {
            line(time: finalTime, color: filledBarColor)
            line(time: currentTime, color: headColor)
            if (haloColor != nil) {
                head(
                    radius: settings.chartHeadPrimaryHaloSize,
                    color: haloColor!
                )
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
        .stroke(lineWidth: 2)
        .foregroundColor(color)
    }
}

struct TimeChartPlotView_Previews: PreviewProvider {
    static var previews: some View {
        ConcentrationPlotView(
            settings: TimeChartGeometrySettings(
                chartSize: 300,
                minConcentration: 0,
                maxConcentration: 1,
                minTime: 0,
                maxTime: 1,
                minFinalConcentration: 0.1,
                minFinalTime: 0.1
            ),
            concentrationA: equation,
            concentrationB: equation.inverse,
            initialConcentration: 0.8,
            finalConcentration: 0.2,
            initialTime: 0,
            currentTime: 0.8,
            finalTime: 1
        )
    }

    static var equation = LinearConcentration(t1: 0, c1: 0.8, t2: 1, c2: 0.2)
}
