//
// Reactions App
//

import SwiftUI

public protocol RGBEquation {
    func getRgb(at x: CGFloat) -> RGB
}

public struct LinearRGBEquation: RGBEquation {

    public init(initialX: CGFloat, finalX: CGFloat, initialColor: RGB, finalColor: RGB) {
        self.initialX = initialX
        self.finalX = finalX
        self.initialColor = initialColor
        self.finalColor = finalColor
    }

    let initialX: CGFloat
    let finalX: CGFloat
    let initialColor: RGB
    let finalColor: RGB

    public func getRgb(at x: CGFloat) -> RGB {
        let fraction = abs((x - initialX) / (finalX - initialX))
        let boundFraction = fraction.within(min: 0, max: 1)
        return RGB.interpolate(initialColor, finalColor, fraction: Double(boundFraction))
    }
}

public struct RGBGradientEquation: RGBEquation {

    public init(colors: [RGB], initialX: CGFloat, finalX: CGFloat) {
        precondition(!colors.isEmpty, "Colors must not be empty")
        precondition(finalX > initialX, "Final X must occur after initial x")
        self.deltaX = (finalX - initialX) / CGFloat(colors.count - 1)
        self.colors = colors
        self.initialX = initialX
        self.finalX = finalX
    }

    let colors: [RGB]
    let initialX: CGFloat
    let finalX: CGFloat

    private let deltaX: CGFloat

    public func getRgb(at x: CGFloat) -> RGB {
        let fraction = (x - initialX) / (finalX - initialX)
        let startIndex = Int(fraction / deltaX)
        let endIndex = startIndex + 1

        let startColor = colors[safe: startIndex] ?? .black
        let endColor = colors[safe: endIndex] ?? .black

        return LinearRGBEquation(
            initialX: CGFloat(startIndex) * deltaX,
            finalX: CGFloat(endIndex) * deltaX,
            initialColor: startColor,
            finalColor: endColor
        ).getRgb(at: x)
    }

    public var gradient: Gradient {
        Gradient(colors: colors.map(\.color))
    }
}
