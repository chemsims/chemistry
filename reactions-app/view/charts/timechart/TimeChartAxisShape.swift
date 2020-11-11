//
// Reactions App
//
  

import SwiftUI


struct TimeChartAxisShape: Shape {
    let verticalTicks: Int
    let horizontalTicks: Int

    let tickSize: CGFloat

    let gapToTop: CGFloat
    let gapToSide: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addRect(rect)
        let dy = (rect.height - gapToTop) / CGFloat(verticalTicks)
        for i in 1...verticalTicks {
            let distanceFromBottom = CGFloat(i) * dy
            let y = rect.height - distanceFromBottom
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: tickSize, y: y))
        }

        let dx = (rect.width - gapToSide) / CGFloat(horizontalTicks)
        for i in 1...horizontalTicks {
            let x = CGFloat(i) * dx
            path.move(to: CGPoint(x: x, y: rect.height))
            path.addLine(to: CGPoint(x: x, y: rect.height - tickSize))
        }
        return path
    }

}


struct TimeChartAxisShape_Previews: PreviewProvider {
    static var previews: some View {
        TimeChartAxisShape(
            verticalTicks: 10,
            horizontalTicks: 10,
            tickSize: 10,
            gapToTop: 100,
            gapToSide: 100
        )
        .stroke()
        .frame(width: 350, height: 350)
    }
}
