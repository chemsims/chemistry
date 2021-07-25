//
// Reactions App
//

import SwiftUI

struct ConcentrationEquationPlotter: Shape {

    let equation: ConcentrationEquation

    let yAxis: SliderCalculations<CGFloat>
    let xAxis: SliderCalculations<CGFloat>

    let initialTime: CGFloat
    var finalTime: CGFloat

    private let maxWidthSteps = 100

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let initialConcentration = equation.getConcentration(at: Double(initialTime))

        let initialX = xAxis.getHandleCenter(at: initialTime)
        let initialY = yAxis.getHandleCenter(at: CGFloat(initialConcentration))

        let dx = rect.width / CGFloat(maxWidthSteps)
        let dt = xAxis.getValue(forHandle: dx) - xAxis.getValue(forHandle: 0)

        path.move(to: CGPoint(x: initialX, y: initialY))

        for t in stride(from: initialTime, to: finalTime, by: dt) {
            let concentration = equation.getConcentration(at: Double(t))
            let x = xAxis.getHandleCenter(at: t)
            let y = yAxis.getHandleCenter(at: CGFloat(concentration))
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }

    var animatableData: CGFloat {
        get { finalTime }
        set { finalTime = newValue }
    }

}

struct TimeChartPlot_Previews: PreviewProvider {

    static var previews: some View {
        ViewStateWrapper()
    }

    struct DummyEquation: ConcentrationEquation {
        func getConcentration(at time: Double) -> Double {
            return time
        }
    }

    struct ViewStateWrapper: View {
        @State var t2: CGFloat = 0

        var body: some View {
            VStack {
                ConcentrationEquationPlotter(
                    equation: DummyEquation(),
                    yAxis: SliderCalculations(
                        minValuePosition: 240,
                        maxValuePosition: 10,
                        minValue: 0,
                        maxValue: 50),
                    xAxis: SliderCalculations(
                        minValuePosition: 10,
                        maxValuePosition: 250 - 10,
                        minValue: 0,
                        maxValue: 50
                    ),
                    initialTime: 0,
                    finalTime: t2
                )
                .stroke(lineWidth: 2)
                .frame(width: 250, height: 250)
                .border(Color.red)

                Button(action: {
                    withAnimation(.linear(duration: 1)) {
                        if self.t2 == 50 {
                            self.t2 = 0
                        } else {
                            self.t2 = 50
                        }
                        self.t2 = 50
                    }
                }) {
                    Text("Click me")
                }
            }
        }
    }
}
