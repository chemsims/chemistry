//
// Reactions App
//


import SwiftUI

public struct TimeChartDataLine {
    let equation: Equation
    let headColor: Color
    let haloColor: Color?
    let headRadius: CGFloat
    let discontinuity: CGPoint?

    public init(
        equation: Equation,
        headColor: Color,
        haloColor: Color?,
        headRadius: CGFloat,
        discontinuity: CGPoint? = nil
    ) {
        self.equation = equation
        self.headColor = headColor
        self.haloColor = haloColor
        self.headRadius = headRadius
        self.discontinuity = discontinuity
    }
}
