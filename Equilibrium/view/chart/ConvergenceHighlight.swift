//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct EquilibriumHighlight: View {

    let equilibriumTime: CGFloat
    let chartSize: CGFloat
    let xAxis: LinearAxis<CGFloat>
    let offset: CGFloat

    var body: some View {
        Path { p in
            let lhsX = xAxis.getPosition(at: equilibriumTime - offset)
            p.move(to: CGPoint(x: lhsX, y: 0))
            p.addLines([
                CGPoint(x: chartSize, y: 0),
                CGPoint(x: chartSize, y: chartSize),
                CGPoint(x: lhsX, y: chartSize),
                CGPoint(x: lhsX, y: 0)
            ])
        }
        .fill(Color.white)
    }
}
