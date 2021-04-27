//
// Reactions App
//

import CoreGraphics
import ReactionsCore

protocol GeneralRGBEquation {
    func getRgb(at x: CGFloat) -> RGB
}

// TODO - rename
struct RGBEquation {

    let initialX: CGFloat
    let finalX: CGFloat
    let initialColor: RGB
    let finalColor: RGB

    func getRgb(at x: CGFloat) -> RGB {
        let fraction = abs((x - initialX) / (finalX - initialX))
        let boundFraction = fraction.within(min: 0, max: 1)
        return RGB.interpolate(initialColor, finalColor, fraction: Double(boundFraction))
    }
}

struct RGBGradientEquation: GeneralRGBEquation {
    let colors: [RGB]
    let initialX: CGFloat
    let finalX: CGFloat

    init(colors: [RGB], initialX: CGFloat, finalX: CGFloat) {
        precondition(!colors.isEmpty, "Colors must not be empty")
        precondition(finalX > initialX, "Final X must occur after initial x")
        self.deltaX = (finalX - initialX) / CGFloat(colors.count - 1)
        self.colors = colors
        self.initialX = initialX
        self.finalX = finalX
    }

    private let deltaX: CGFloat

    func getRgb(at x: CGFloat) -> RGB {
        let fraction = (x - initialX) / (finalX - initialX)
        let startIndex = Int(fraction / deltaX)
        let endIndex = startIndex + 1

        let startColor = colors[safe: startIndex] ?? .black
        let endColor = colors[safe: endIndex] ?? .black

        return RGBEquation(
            initialX: CGFloat(startIndex) * deltaX,
            finalX: CGFloat(endIndex) * deltaX,
            initialColor: startColor,
            finalColor: endColor
        ).getRgb(at: x)
    }

}
