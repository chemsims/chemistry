//
// Reactions App
//

import CoreGraphics

public struct ChartAxisShapeSettings {
    public let verticalTicks: Int
    public let horizontalTicks: Int
    public let tickSize: CGFloat
    public let gapToTop: CGFloat
    public let gapToSide: CGFloat
    public let lineWidth: CGFloat = 1

    public init(
        verticalTicks: Int,
        horizontalTicks: Int,
        tickSize: CGFloat,
        gapToTop: CGFloat,
        gapToSide: CGFloat
    ) {
        self.verticalTicks = verticalTicks
        self.horizontalTicks = horizontalTicks
        self.tickSize = tickSize
        self.gapToTop = gapToTop
        self.gapToSide = gapToSide
    }

    /// Creates a default geometry based on the provided `chartSize`
    public init(chartSize: CGFloat) {
        self.init(
            verticalTicks: 10,
            horizontalTicks: 10,
            tickSize: 0.04 * chartSize,
            gapToTop: 0.24 * chartSize,
            gapToSide: 0.24 * chartSize
        )
    }
}
