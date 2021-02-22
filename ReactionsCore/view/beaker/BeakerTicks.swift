//
// ReactionsCore
//

import SwiftUI

public struct BeakerTicks: Shape {

    /// The total number of ticks
    let numTicks: Int

    /// Distance from right side of ticks to the right edge of the frame
    let rightGap: CGFloat

    /// Distance from bottom tick to the bottom of the frame
    let bottomGap: CGFloat

    /// Distance from top tick to the top of the frame
    let topGap: CGFloat

    /// Width of minor ticks
    let minorWidth: CGFloat

    /// Width of major ticks
    let majorWidth: CGFloat

    public init(
        numTicks: Int,
        rightGap: CGFloat,
        bottomGap: CGFloat,
        topGap: CGFloat,
        minorWidth: CGFloat,
        majorWidth: CGFloat
    ) {
        self.numTicks = numTicks
        self.rightGap = rightGap
        self.bottomGap = bottomGap
        self.topGap = topGap
        self.minorWidth = minorWidth
        self.majorWidth = majorWidth
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let dy = (rect.height - topGap - bottomGap) / CGFloat(numTicks - 1)
        let rightX = rect.width - rightGap
        for i in 0..<numTicks {
            let width = (i + 1) % 5 == 0 ? majorWidth : minorWidth
            let y = rect.height - bottomGap - (dy * CGFloat(i))
            path.move(to: CGPoint(x: rightX, y: y))
            path.addLine(to: CGPoint(x: rightX - width, y: y))
        }

        return path
    }

}

struct BeakerTicks_Previews: PreviewProvider {
    static var previews: some View {
        BeakerTicks(
            numTicks: 13,
            rightGap: 100,
            bottomGap: 20,
            topGap: 20,
            minorWidth: 100,
            majorWidth: 200
        ).stroke()
    }
}
