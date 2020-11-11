//
// Reactions App
//
  

import SwiftUI

struct ConcentrationBarChart<Value>: View where Value: BinaryFloatingPoint {

    let concentrationA: ValueRange<Value>

    let maxValueGapToTop: CGFloat = 80
    let zeroHeight: CGFloat = 20

    private let ticks = 10
    private let tickSize: CGFloat = 15
    private let height: CGFloat = 300
    private let barWidth: CGFloat = 45
    private let barAGapToAxis: CGFloat = 60
    private let labelDiameter: CGFloat = 30

    var body: some View {
        VStack {
            ZStack {
                BarChartMinorAxisShape(ticks: 10)
                    .stroke(lineWidth: 0.3)
                BarChartAxisShape(ticks: ticks, tickSize: tickSize)
                    .stroke(lineWidth: 1.4)

                drawBar(value: concentrationA)
                    .foregroundColor(Styling.moleculeA)

            }.frame(width: 300, height: height)

            VStack {
                Circle()
                    .frame(width: labelDiameter, height: labelDiameter)
                    .foregroundColor(Styling.moleculeA)

                Text("A")
            }
            .position(x: barAGapToAxis, y: labelDiameter)
        }.frame(width: 300)
    }

    private func drawBar(value: ValueRange<Value>) -> some View {
        let barHeight = CGFloat(value.percentage) * maxBarHeight
        let yPos = height - (barHeight / 2) - tickDy
        return Rectangle()
            .frame(width: barWidth, height: barHeight)
            .position(x: barAGapToAxis, y: yPos)
    }

    private var maxBarHeight: CGFloat {
        height - tickDy - maxValueGapToTop
    }

    private var tickDy: CGFloat {
        height / CGFloat(ticks + 1)
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
            concentrationA: ValueRange(value: 20, minValue: 0, maxValue: 20)
        )
    }
}
