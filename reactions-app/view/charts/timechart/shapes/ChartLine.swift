//
// Reactions App
//

import SwiftUI

struct ChartLine: Shape {

    let equation: Equation

    let yAxis: AxisPositionCalculations<CGFloat>
    let xAxis: AxisPositionCalculations<CGFloat>

    let startX: CGFloat
    var endX: CGFloat

    private let maxWidthSteps = 100

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let dxPos = rect.width / CGFloat(maxWidthSteps)
        let dx = xAxis.getValue(at: dxPos) - xAxis.getValue(at: 0)

        var didStart = false
        for x in stride(from: startX, to: endX, by: dx) {
            let y = equation.getY(at: x)
            let xPosition = xAxis.getPosition(at: x)
            let yPosition = yAxis.getPosition(at: y)
            if didStart {
                path.addLine(to: CGPoint(x: xPosition, y: yPosition))
            } else {
                path.move(to: CGPoint(x: xPosition, y: yPosition))
                didStart = true
            }
        }

        return path
    }

    var animatableData: CGFloat {
        get { endX }
        set { endX = newValue }
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

    struct ViewStateWrapper: View {
        @State var t2: CGFloat = 0

        var body: some View {
            VStack {
                ZStack {
                    ChartLine(
                        equation: IdentityEquation(),
                        yAxis: yAxis,
                        xAxis: xAxis,
                        startX: 0,
                        endX: t2
                    ).stroke(lineWidth: 2)

                    ChartIndicatorHead(
                        radius: 10,
                        equation: IdentityEquation(),
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
