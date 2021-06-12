//
// Reactions App
//


import SwiftUI

/// Represents a single data line in a chart.
///
/// When plotting a chart, we pass in some range of `x` values, which are then
/// passed to the provided `equation`, and this gives us the `y` values to plot.
/// These `y` values are converted to positions using an instance of `AxisPositionCalculations`.
///
/// Typically, the range of `x` values are used to find the `x` position, by another instance of `AxisPositionCalculations`.
/// It is also possible to provide an explicit `xEquation`, to customise this behaviour. For example, this may be done to use
/// a log scale on the x axis. In this case, the range of `x ` values passed in to the chart is unchanged. However, when we
/// convert this value into a position along the x axis, we first pass it through the `xEquation` which transforms it - in this
/// case applying a logarithm. This transformed value is then passed into the `AxisPositionCalculations` to return a position.
///
/// Without providing an `xEquation`, then if we animate the input `x` linearly, then the chart will also progress linearly along the x
/// axis. In the example of passing a log equation instead, then the chart will move as the log of the input `x`.
public struct TimeChartDataLine {
    let equation: Equation
    let xEquation: Equation?
    let headColor: Color
    let haloColor: Color?
    let headRadius: CGFloat
    let discontinuity: CGPoint?
    let showFilledLine: Bool

    /// Creates a new data line
    ///
    /// - Parameters:
    ///     - equation: Equation which returns the `y` value to plot
    ///     - xEquation: Equation to return a `x` value, which is used to control the value along the x axis.
    ///     When no equation is given, the chart input is used as the `x` value
    public init(
        equation: Equation,
        xEquation: Equation? = nil,
        headColor: Color,
        haloColor: Color?,
        headRadius: CGFloat,
        discontinuity: CGPoint? = nil,
        showFilledLine: Bool = true
    ) {
        self.equation = equation
        self.xEquation = xEquation
        self.headColor = headColor
        self.haloColor = haloColor
        self.headRadius = headRadius
        self.discontinuity = discontinuity
        self.showFilledLine = showFilledLine
    }
}
