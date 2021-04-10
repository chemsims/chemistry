//
// Reactions App
//

import CoreGraphics
import ReactionsCore

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
