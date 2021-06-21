//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct TitrationEquationLayout {
    let fontSize: CGFloat = EquationSizing.fontSize
    let rowHeight: CGFloat = 100
    let equationVerticalSpacing: CGFloat = 50
    let columnWidth: CGFloat = 200

    let boxWidth: CGFloat = EquationSizing.boxWidth

    let termsHSpacing: CGFloat = 5
    let fractionVSpacing: CGFloat = 3

    let fractionBarHeight: CGFloat = 2

    let minScaleFactor: CGFloat = 0.1

    let fractionParenHeightScaleFactor: CGFloat = 2
}
