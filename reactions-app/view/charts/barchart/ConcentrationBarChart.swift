//
// Reactions App
//
  

import SwiftUI

struct ConcentrationBarChart: View {

    let initialA: CGFloat
    let initialTime: CGFloat
    let concentrationA: ConcentrationEquation
    let concentrationB: ConcentrationEquation

    let currentTime: CGFloat?

    let settings: BarChartGeometrySettings

    var body: some View {
        VStack {
            ZStack {
                BarChartMinorAxisShape(ticks: settings.ticks)
                    .stroke(lineWidth: 0.3)
                BarChartAxisShape(ticks: settings.ticks, tickSize: settings.yAxisTickSize)
                    .stroke(lineWidth: 1.4)

                barA
                barB

            }.frame(width: settings.chartWidth, height: settings.chartWidth)
            ZStack {
                drawLabel(label: "A", color: Styling.moleculeA, barX: settings.barACenterX)
                drawLabel(label: "B", color: Styling.moleculeB, barX: settings.barBCenterX)
            }
        }
    }

    private var barA: some View {
        return ZStack {
            drawBar(
                concentration: ConstantConcentration(value: initialA),
                currentTime: 0,
                barCenterX: settings.barACenterX
            ).foregroundColor(currentTime == nil ? Styling.moleculeA : Color.gray)

            if (currentTime != nil) {
                drawBar(
                    concentration: concentrationA,
                    currentTime: currentTime!,
                    barCenterX: settings.barACenterX
                ).foregroundColor(Styling.moleculeA)
            }
        }
    }

    private var barB: some View {
        ZStack {
            if (currentTime == nil) {
                drawBar(
                    concentration: ConstantConcentration(value: 0),
                    currentTime: 0,
                    barCenterX: settings.barBCenterX
                )
            }
            if (currentTime != nil) {
                drawBar(
                    concentration: concentrationB,
                    currentTime: currentTime!,
                    barCenterX: settings.barBCenterX
                )
            }
        }.foregroundColor(Styling.moleculeB)
    }

    private func drawBar(
        concentration: ConcentrationEquation,
        currentTime: CGFloat,
        barCenterX: CGFloat
    ) -> some View {
        return BarChartBarShape(
            settings: settings,
            concentrationEquation: concentration,
            barCenterX: barCenterX,
            currentTime: currentTime
        )
    }

    private func drawLabel(
        label: String,
        color: Color,
        barX: CGFloat
    ) -> some View {
        VStack {
            Circle()
                .frame(width: settings.labelDiameter, height: settings.labelDiameter)
                .foregroundColor(color)

            Text(label)
                .font(.system(size: settings.labelFontSize))
        }.offset(x: barX - (settings.chartWidth / 2))
    }

}





struct BarChartAxisShape_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ConcentrationBarChart(
                initialA: 1,
                initialTime: 0.1,
                concentrationA: equation,
                concentrationB: equation2,
                currentTime: nil,
                settings: BarChartGeometrySettings(
                    chartWidth: 300,
                    maxConcentration: 1,
                    minConcentration: 0
                )
            )

            ConcentrationBarChart(
                initialA: 1,
                initialTime: 0.1,
                concentrationA: equation,
                concentrationB: equation2,
                currentTime: 1.5,
                settings: BarChartGeometrySettings(
                    chartWidth: 300,
                    maxConcentration: 1,
                    minConcentration: 0
                )
            )
        }
    }

    private static var equation = LinearConcentration(
        t1: 1,
        c1: 1,
        t2: 2,
        c2: 0.2
    )

    private static var equation2 = LinearConcentration(
        t1: 1,
        c1: 0.2,
        t2: 2,
        c2: 1
    )
}
