//
// Reactions App
//

import CoreGraphics

/// Provides default equation values for equation sizing
public struct EquationSizing {
    /// Standard font size - fits up to 2 decimal places into a box width
    public static let fontSize: CGFloat = 30

    /// Standard font size to fit 3 decimal places into a box width
    public static let tripleDecimalFontSize: CGFloat = 24

    /// Standard font size for subscripts & superscripts
    public static let subscriptFontSize: CGFloat = 22

    public static let boxHeight: CGFloat = 50
    public static let boxWidth: CGFloat = 70
    public static let boxSize = CGSize(width: boxWidth, height: boxHeight)
    public static let boxPadding: CGFloat = 10
}
