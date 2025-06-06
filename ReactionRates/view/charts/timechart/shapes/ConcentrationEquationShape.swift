//
// Reactions App
//

import SwiftUI

struct ChartLine: Shape {

    let equation: Equation

    let yAxis: AxisPositionCalculations<CGFloat>
    let xAxis: AxisPositionCalculations<CGFloat>

    let initialTime: CGFloat
    var finalTime: CGFloat

    private let maxWidthSteps = 100

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let dx = rect.width / CGFloat(maxWidthSteps)
        let dt = xAxis.getValue(at: dx) - xAxis.getValue(at: 0)

        var didStart = false
        for t in stride(from: initialTime, to: finalTime, by: dt) {
            let concentration = equation.getY(at: t)
            let x = xAxis.getPosition(at: t)
            let y = yAxis.getPosition(at: concentration)
            if didStart {
                path.addLine(to: CGPoint(x: x, y: y))
            } else {
                path.move(to: CGPoint(x: x, y: y))
                didStart = true
            }
        }

        return path
    }

    var animatableData: CGFloat {
        get { finalTime }
        set { finalTime = newValue }
    }

}

struct ChartIndicatorHead: Shape {

    let radius: CGFloat
    let equation: Equation

    let yAxis: AxisPositionCalculations<CGFloat>
    let xAxis: AxisPositionCalculations<CGFloat>

    var x: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let y = equation.getY(at: x)

        let xPosition = xAxis.getPosition(at: x)
        let yPosition = yAxis.getPosition(at: y)

        let containerRect = CGRect(
            origin: CGPoint(x: xPosition - radius, y: yPosition - radius),
            size: CGSize(width: radius * 2, height: radius * 2)
        )
        path.addEllipse(in: containerRect)

        return path
    }

    var animatableData: CGFloat {
        get { x }
        set { x = newValue }
    }

}

struct TimeChartPlot_Previews: PreviewProvider {

    static var previews: some View {
        ViewStateWrapper()
    }

    struct DummyEquation: ConcentrationEquation {
        func getConcentration(at time: CGFloat) -> CGFloat {
            return time
        }
    }

    struct ViewStateWrapper: View {
        @State var t2: CGFloat = 0

        var body: some View {
            VStack {
                ZStack {
                    ChartLine(
                        equation: DummyEquation(),
                        yAxis: yAxis,
                        xAxis: xAxis,
                        initialTime: 0,
                        finalTime: t2
                    ).stroke(lineWidth: 2)

                    ChartIndicatorHead(
                        radius: 10,
                        equation: DummyEquation(),
                        yAxis: yAxis,
                        xAxis: xAxis,
                        x: t2
                    )
                }
                .frame(width: 250, height: 250)
                .border(Color.red)

                Button(action: {
                    withAnimation(.linear(duration: 1)) {
                        if self.t2 == 50 {
                            self.t2 = 0
                        } else {
                            self.t2 = 50
                        }
                    }
                }) {
                    Text("Click me")
                }
            }
        }

        private var yAxis: AxisPositionCalculations<CGFloat> {
            AxisPositionCalculations(
                minValuePosition: 240,
                maxValuePosition: 10,
                minValue: 0,
                maxValue: 50)
        }

        private var xAxis: AxisPositionCalculations<CGFloat> {
            AxisPositionCalculations(
                minValuePosition: 10,
                maxValuePosition: 250 - 10,
                minValue: 0,
                maxValue: 50
            )
        }
    }
}
