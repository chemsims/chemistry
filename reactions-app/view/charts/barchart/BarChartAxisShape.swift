//
// Reactions App
//
  

import SwiftUI

struct BartChartGeometrySettings {

    let chartWidth: CGFloat
    let maxConcentration: CGFloat
    let minConcentration: CGFloat

    let ticks = 10

    var maxValueGapToTop: CGFloat {
        0.25 * chartWidth
    }
    var zeroHeight: CGFloat {
        0.07 * chartWidth
    }

    var tickSize: CGFloat {
        0.05 * chartWidth
    }
    var barWidth: CGFloat {
        0.15 * chartWidth
    }
    var barAGapToAxis: CGFloat {
        0.2 * chartWidth
    }
    var labelDiameter: CGFloat {
        0.1 * chartWidth
    }
    var labelFontSize: CGFloat {
        0.1 * chartWidth
    }

}

struct ConcentrationBarChart: View {

    let concentrationA: CGFloat
    let settings: BartChartGeometrySettings

    var body: some View {
        VStack {
            ZStack {
                BarChartMinorAxisShape(ticks: 10)
                    .stroke(lineWidth: 0.3)
                BarChartAxisShape(ticks: settings.ticks, tickSize: settings.tickSize)
                    .stroke(lineWidth: 1.4)

                drawBar
                    .foregroundColor(Styling.moleculeA)

            }.frame(width: settings.chartWidth, height: settings.chartWidth)

            VStack {
                Circle()
                    .frame(width: settings.labelDiameter, height: settings.labelDiameter)
                    .foregroundColor(Styling.moleculeA)

                Text("A")
                    .font(.system(size: settings.labelFontSize))
            }.offset(x: settings.barAGapToAxis - (settings.chartWidth / 2))
        }
    }

    private var drawBar: some View {
        let valuePercentage = concentrationA / (settings.maxConcentration - settings.minConcentration)
        let barHeight = valuePercentage * maxBarHeight
        let yPos = settings.chartWidth - (barHeight / 2) - tickDy
        return Rectangle()
            .frame(width: settings.barWidth, height: barHeight)
            .position(x: settings.barAGapToAxis, y: yPos)
    }

    private var maxBarHeight: CGFloat {
        settings.chartWidth - tickDy - settings.maxValueGapToTop
    }

    private var tickDy: CGFloat {
        settings.chartWidth / CGFloat(settings.ticks + 1)
    }
}


struct BarChartAxisShape: Shape {

    let ticks: Int
    let tickSize: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addLines([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: rect.height),
            CGPoint(x: rect.width, y: rect.height),
            CGPoint(x: rect.width, y: 0),
        ])

        let dy = rect.height / CGFloat(ticks + 1) // +1 to leave a gap at the top
        for i in 1...ticks {
            let y = CGFloat(i) * dy
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: tickSize, y: y))
        }

        return path
    }
}

struct BarChartMinorAxisShape: Shape {

    let ticks: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let dy = rect.height / CGFloat(ticks + 1)

        for i in 1...ticks {
            let y = CGFloat(i) * dy
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }

        return path
    }
}

struct BarChartAxisShape_Previews: PreviewProvider {
    static var previews: some View {
        ConcentrationBarChart(
            concentrationA: 20,
            settings: BartChartGeometrySettings(
                chartWidth: 300,
                maxConcentration: 20,
                minConcentration: 0
            )
        )
    }
}
