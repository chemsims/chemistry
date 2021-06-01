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
    let showFilledLine: Bool

    public init(
        equation: Equation,
        headColor: Color,
        haloColor: Color?,
        headRadius: CGFloat,
        discontinuity: CGPoint? = nil,
        showFilledLine: Bool = true
    ) {
        self.equation = equation
        self.headColor = headColor
        self.haloColor = haloColor
        self.headRadius = headRadius
        self.discontinuity = discontinuity
        self.showFilledLine = showFilledLine
    }
}
