//
// Reactions App
//


import SwiftUI

public struct TimeChartDataline {
    let equation: Equation
    let headColor: Color
    let haloColor: Color?
    let headRadius: CGFloat
    let haloSize: CGFloat

    public init(
        equation: Equation,
        headColor: Color,
        haloColor: Color?,
        headRadius: CGFloat,
        haloSize: CGFloat
    ) {
        self.equation = equation
        self.headColor = headColor
        self.haloColor = haloColor
        self.headRadius = headRadius
        self.haloSize = haloSize
    }
}
