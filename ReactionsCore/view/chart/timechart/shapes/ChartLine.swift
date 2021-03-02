//
// Reactions App
//

import SwiftUI

public struct ChartLine: Shape {

    let equation: Equation

    let yAxis: AxisPositionCalculations<CGFloat>
    let xAxis: AxisPositionCalculations<CGFloat>

    let startX: CGFloat
    var endX: CGFloat

    var offset: CGFloat

    let discontinuity: CGFloat?

    public init(
        equation: Equation,
        yAxis: AxisPositionCalculations<CGFloat>,
        xAxis: AxisPositionCalculations<CGFloat>,
        startX: CGFloat,
        endX: CGFloat,
        offset: CGFloat = 0,
        discontinuity: CGFloat? = nil
    ) {
        self.equation = equation
        self.yAxis = yAxis
        self.xAxis = xAxis
        self.startX = startX
        self.endX = endX
        self.offset = offset
        self.discontinuity = discontinuity
    }

    private let maxWidthSteps = 100

    private var shiftedXAxis: AxisPositionCalculations<CGFloat> {
        xAxis.shift(by: offset)
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let dxPos = rect.width / CGFloat(maxWidthSteps)
        let dx = shiftedXAxis.getValue(at: dxPos) - shiftedXAxis.getValue(at: 0)

        var didStart = false

        for x in getStride(dx: dx) {
            let y = equation.getY(at: x)
            let xPosition = shiftedXAxis.getPosition(at: x)
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

    private func getStride(
        dx: CGFloat
    ) -> [CGFloat] {
        if let discontinuity = discontinuity, discontinuity > startX && discontinuity < endX {
            var lhs = Array(stride(from: startX + offset, through : discontinuity, by: dx))
            if lhs.last != discontinuity {
                lhs.append(discontinuity)
            }
            let rhs = Array(stride(from: discontinuity + dx, through: endX, by: dx))
            return (lhs + rhs)

        } else {
            return Array(stride(from: startX + offset, through : endX, by: dx))
        }
    }

    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(offset, endX)  }
        set {
            offset = newValue.first
            endX = newValue.second
        }
    }

}

struct ChartIndicatorHead: Shape {

    let radius: CGFloat
    let equation: Equation

    let yAxis: AxisPositionCalculations<CGFloat>
    let xAxis: AxisPositionCalculations<CGFloat>

    var x: CGFloat
    var offset: CGFloat

    private var shiftedXAxis: AxisPositionCalculations<CGFloat> {
        xAxis.shift(by: offset)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let y = equation.getY(at: x)

        let xPosition = shiftedXAxis.getPosition(at: x)
        let yPosition = yAxis.getPosition(at: y)

        let containerRect = CGRect(
            origin: CGPoint(x: xPosition - radius, y: yPosition - radius),
            size: CGSize(width: radius * 2, height: radius * 2)
        )
        path.addEllipse(in: containerRect)

        return path
    }

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(offset, x) }
        set {
            offset = newValue.first
            x = newValue.second
        }
    }

}

struct ChartLine_Previews: PreviewProvider {

    static var previews: some View {
        ViewStateWrapper()
    }

    struct ViewStateWrapper: View {
        @State var t2: CGFloat = 34.01

        var body: some View {
            VStack {
                ZStack {
                    ChartLine(
                        equation: discontinuousEquation(),
                        yAxis: yAxis,
                        xAxis: xAxis,
                        startX: 0,
                        endX: t2,
                        discontinuity: 34
                    ).stroke(lineWidth: 2)

                    ChartIndicatorHead(
                        radius: 10,
                        equation: discontinuousEquation(),
                        yAxis: yAxis,
                        xAxis: xAxis,
                        x: t2,
                        offset: 0
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

    private static func discontinuousEquation() -> Equation {
        SwitchingEquation(
            thresholdX: 34,
            underlyingLeft: LinearEquation(m: 1, x1: 0, y1: 0),
            underlyingRight: ConstantEquation(value: 20
            )
        )
    }
}


