//
// Reactions App
//

import SwiftUI

struct BarShape: Shape {

    let equation: Equation
    var time: CGFloat
    let axis: LinearAxis<CGFloat>

    var animatableData: CGFloat {
        get { time }
        set { time = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let yValue = equation.getValue(at: time)
        let yPos = axis.getPosition(at: yValue)

        let bar = CGRect(
            origin: CGPoint(x: 0, y: yPos),
            size: CGSize(
                width: rect.width,
                height: max(0, rect.height - yPos)
            )
        )
        path.addRect(bar)
        return path
    }
}

struct BarShape_Previews: PreviewProvider {
    static var previews: some View {
        BarShape(
            equation: LinearEquation(m: 1, x1: 0, y1: 0),
            time: 0.1,
            axis: LinearAxis(
                minValuePosition: 90,
                maxValuePosition: 0,
                minValue: 0,
                maxValue: 1
            )
        )
        .frame(width: 20, height: 100)
        .border(Color.red)
    }
}
