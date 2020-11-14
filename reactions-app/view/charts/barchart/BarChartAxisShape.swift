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

    let initialA: CGFloat
    let initialTime: CGFloat
    let concentrationA: ConcentrationEquation
    let concentrationB: ConcentrationEquation

    let currentTime: CGFloat?

    let settings: BartChartGeometrySettings

    var body: some View {
        VStack {
            ZStack {
                BarChartMinorAxisShape(ticks: 10)
                    .stroke(lineWidth: 0.3)
                BarChartAxisShape(ticks: settings.ticks, tickSize: settings.tickSize)
                    .stroke(lineWidth: 1.4)

                barA
                barB

            }.frame(width: settings.chartWidth, height: settings.chartWidth)
            ZStack {
                drawLabel(label: "A", color: Styling.moleculeA, barX: xBarA)
                drawLabel(label: "B", color: Styling.moleculeB, barX: xBarB)
            }
        }
    }

    private var barA: some View {
        return ZStack {
                drawBar(
                    concentration: ConstantConcentration(value: initialA),
                    currentTime: initialTime,
                    isA: true
                ).foregroundColor(currentTime == nil ? Styling.moleculeA : Color.gray)

            if (currentTime != nil) {
                drawBar(
                    concentration: concentrationA,
                    currentTime: currentTime!,
                    isA: true
                ).foregroundColor(Styling.moleculeA)
            }

        }
    }

    private var barB: some View {
        ZStack {
            if (currentTime != nil) {
                drawBar(
                    concentration: concentrationB,
                    currentTime: currentTime!,
                    isA: false
                ).foregroundColor(Styling.moleculeB)
            }
        }
    }

    private var xBarA: CGFloat {
        settings.chartWidth / 4
    }

    private var xBarB: CGFloat {
        (settings.chartWidth / 4) * 3
    }

    private func drawBar(
        concentration: ConcentrationEquation,
        currentTime: CGFloat,
        isA: Bool
    ) -> some View {
        return BarChartBarShape(
            settings: settings,
            concentrationEquation: concentration,
            currentTime: currentTime,
            isA: isA
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

    private var maxBarHeight: CGFloat {
        settings.chartWidth - tickDy - settings.maxValueGapToTop
    }

    private var tickDy: CGFloat {
        settings.chartWidth / CGFloat(settings.ticks + 1)
    }
}


struct BarChartBarShape: Shape {

    let settings: BartChartGeometrySettings

    let concentrationEquation: ConcentrationEquation
    var currentTime: CGFloat
    let isA: Bool

    var animatableData: CGFloat {
        get { currentTime }
        set { currentTime = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tickDy = settings.chartWidth / CGFloat(settings.ticks + 1)

        let maxBarHeight = settings.chartWidth - tickDy - settings.maxValueGapToTop

        let spacing = settings.chartWidth / 4
        let centerX = isA ? spacing : spacing * 3

        let leftX = centerX - (settings.barWidth / 2)
        let bottomY = settings.chartWidth - settings.tickSize

        let concentration = concentrationEquation.getConcentration(at: currentTime)
        let valuePercentage = concentration / (settings.maxConcentration - settings.minConcentration)
        let barHeight = valuePercentage * maxBarHeight

        let topY = bottomY - barHeight

        path.addRect(
            CGRect(
                origin: CGPoint(x: leftX, y: topY),
                size: CGSize(width: settings.barWidth, height: barHeight)
            )
        )

        return path
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
        VStack {
            ConcentrationBarChart(
                initialA: 1,
                initialTime: 0.1,
                concentrationA: equation,
                concentrationB: equation2,
                currentTime: nil,
                settings: BartChartGeometrySettings(
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
                settings: BartChartGeometrySettings(
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
