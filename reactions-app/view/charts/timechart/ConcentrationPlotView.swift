//
// Reactions App
//
  

import SwiftUI

struct ConcentrationPlotView: View {

    let settings: TimeChartGeometrySettings
    let concentrationAEquation: ConcentrationEquation

    let initialTime: CGFloat
    let currentTime: CGFloat
    let finalTime: CGFloat

    private let finalColor: Color = Styling.timeAxisCompleteBar
    private let aProgressColor: Color = .orangeAccent
    private let aProgressHalo: Color = Color.orangeAccent.opacity(0.7)

    var body: some View {
        ZStack {
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
                equation: concentrationAEquation,
                initialTime: initialTime,
                currentTime: currentTime,
                finalTime: finalTime,
                filledBarColor: Styling.timeAxisCompleteBar,
                headColor: Styling.moleculeAChartHead,
                haloColor: Styling.moleculeAChartHeadHalo,
                showHalo: true
            )
        }.frame(width: settings.chartSize, height: settings.chartSize)
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
    let haloColor: Color

    let showHalo: Bool

    var body: some View {
        ZStack {
            axis(time: finalTime, color: filledBarColor)
            axis(time: currentTime, color: headColor)
            head(
                radius: settings.chartHeadPrimaryHaloSize,
                color: haloColor
            )
            head(
                radius: settings.chartHeadPrimarySize,
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
            yAxis: settings.yAxis(CGFloat.init),
            xAxis: settings.xAxis(CGFloat.init),
            time: currentTime
        )
        .fill()
        .foregroundColor(color)
    }

    private func axis(
        time: CGFloat,
        color: Color
    ) -> some View {
        ConcentrationEquationShape(
            equation: equation,
            yAxis: settings.yAxis(CGFloat.init),
            xAxis: settings.xAxis(CGFloat.init),
            initialTime: initialTime,
            finalTime: time
        )
        .stroke(lineWidth: 3)
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
                maxTime: 1
            ),
            concentrationAEquation: LinearConcentration(t1: 0, c1: 0.8, t2: 1, c2: 0.2),
            initialTime: 0,
            currentTime: 0.5,
            finalTime: 1
        )
    }
}
