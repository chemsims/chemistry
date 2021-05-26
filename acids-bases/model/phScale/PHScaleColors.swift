//
// Reactions App
//

import Foundation
import ReactionsCore

struct PHScaleColors {

    static let colors: [RGB] = [
        RGB(r: 240, g: 148, b: 137),
        RGB(r: 242, g: 169, b: 141),
        RGB(r: 245, g: 193, b: 146),
        RGB(r: 227, g: 221, b: 164),
        RGB(r: 205, g: 251, b: 183),
        RGB(r: 190, g: 240, b: 218),
        RGB(r: 177, g: 228, b: 250),
        RGB(r: 173, g: 201, b: 247),
        RGB(r: 169, g: 174, b: 243)
    ]

    static let RGBEquation: RGBGradientEquation = RGBGradientEquation(
        colors: colors,
        initialX: 0,
        finalX: 1
    )

    static let gradient = RGBEquation.gradient
}
