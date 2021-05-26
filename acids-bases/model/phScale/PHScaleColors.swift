//
// Reactions App
//

import Foundation
import ReactionsCore

struct PHScaleColors {
    static let colors: [RGB] = [
        RGB(r: 227, g: 140, b: 130),
        RGB(r: 242, g: 169, b: 141),
        RGB(r: 244, g: 181, b: 143),
        RGB(r: 245, g: 193, b: 146),
        RGB(r: 238, g: 206, b: 153),
        RGB(r: 226, g: 221, b: 164),
        RGB(r: 214, g: 237, b: 174),
        RGB(r: 205, g: 251, b: 183),
        RGB(r: 197, g: 245, b: 201),
        RGB(r: 190, g: 239, b: 218),
        RGB(r: 181, g: 239, b: 220),
        RGB(r: 183, g: 232, b: 238),
        RGB(r: 177, g: 228, b: 250),
        RGB(r: 174, g: 202, b: 247),
        RGB(r: 170, g: 179, b: 244),
    ]

    static let RGBEquation: RGBGradientEquation = RGBGradientEquation(
        colors: colors,
        initialX: 0,
        finalX: 1
    )

    static let gradient = RGBEquation.gradient
}
