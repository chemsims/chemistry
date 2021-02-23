//
// Reactions App
//

import CoreGraphics

public struct TimeChartLayoutSettings {
    public let xAxis: AxisPositionCalculations<CGFloat>
    public let yAxis: AxisPositionCalculations<CGFloat>
    public let haloRadius: CGFloat
    public let lineWidth: CGFloat

    public init(
        xAxis: AxisPositionCalculations<CGFloat>,
        yAxis: AxisPositionCalculations<CGFloat>,
        haloRadius: CGFloat,
        lineWidth: CGFloat
    ) {
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.haloRadius = haloRadius
        self.lineWidth = lineWidth
    }
}
