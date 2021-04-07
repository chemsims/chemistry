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

    let discontinuity: CGPoint?

    public init(
        equation: Equation,
        yAxis: AxisPositionCalculations<CGFloat>,
        xAxis: AxisPositionCalculations<CGFloat>,
        startX: CGFloat,
        endX: CGFloat,
        offset: CGFloat = 0,
        discontinuity: CGPoint? = nil
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

        func addLine(x: CGFloat, y: CGFloat) {
            let xPosition = shiftedXAxis.getPosition(at: x)
            let yPosition = yAxis.getPosition(at: y)
            if didStart {
                path.addLine(to: CGPoint(x: xPosition, y: yPosition))
            } else {
                path.move(to: CGPoint(x: xPosition, y: yPosition))
                didStart = true
            }
        }

        if let dc = discontinuity {
            for x in strideLhs(dx: dx, discontinuityX: dc.x) {
                let y = equation.getY(at: x)
                addLine(x: x, y: y)
            }
            addLine(x: dc.x - (dx / 100), y: equation.getY(at: dc.x - (dx / 100)))
        }

        for x in strideRhs(dx: dx) {
            let y = equation.getY(at: x)
            addLine(x: x, y: y)
        }
        addLine(x: endX, y: equation.getY(at: endX))

        return path
    }

    private func strideLhs(dx: CGFloat, discontinuityX: CGFloat) -> StrideTo<CGFloat> {
        stride(from: startX + offset, to: discontinuityX, by: dx)
    }

    private func strideRhs(dx: CGFloat) -> StrideTo<CGFloat> {
        if let dc = discontinuity {
            return stride(from: dc.x, to: endX, by: dx)
        } else {
            return stride(from: startX + offset, to: endX, by: dx)
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

public struct ChartIndicatorHead: Shape {

    let radius: CGFloat
    let equation: Equation

    let yAxis: AxisPositionCalculations<CGFloat>
    let xAxis: AxisPositionCalculations<CGFloat>

    var x: CGFloat
    var offset: CGFloat

    public init(
        radius: CGFloat,
        equation: Equation,
        yAxis: AxisPositionCalculations<CGFloat>,
        xAxis: AxisPositionCalculations<CGFloat>,
        x: CGFloat,
        offset: CGFloat
    ) {
        self.radius = radius
        self.equation = equation
        self.yAxis = yAxis
        self.xAxis = xAxis
        self.x = x
        self.offset = offset
    }


    private var shiftedXAxis: AxisPositionCalculations<CGFloat> {
        xAxis.shift(by: offset)
    }

    public func path(in rect: CGRect) -> Path {
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

    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
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
        @State var t2: CGFloat = 34

        var body: some View {
            VStack {
                ZStack {
                    ChartLine(
                        equation: discontinuousEquation(),
                        yAxis: yAxis,
                        xAxis: xAxis,
                        startX: 0,
                        endX: t2,
                        discontinuity: CGPoint(x: 34, y: 34)
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
