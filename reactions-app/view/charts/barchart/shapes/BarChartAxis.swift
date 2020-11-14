//
// Reactions App
//
  

import SwiftUI


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
