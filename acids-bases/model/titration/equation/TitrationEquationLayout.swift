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

    let boxWidth: CGFloat = 1.5 * EquationSizing.boxWidth
    let boxHeight: CGFloat = EquationSizing.boxHeight

    let termsHSpacing: CGFloat = 5
    let fractionVSpacing: CGFloat = 3

    let fractionBarHeight: CGFloat = 2

    let minScaleFactor: CGFloat = 0.1

    let fractionParenHeightScaleFactor: CGFloat = 2.2

    func boxWidth(forFormatter formatter: EquationTermFormatter) -> CGFloat {
        switch formatter {
        case .scientific: return wideBoxWidth
        case let .decimals(places) where places > 2: return wideBoxWidth
        default: return EquationSizing.boxWidth
        }
    }

    private let wideBoxWidth = 1.5 * EquationSizing.boxWidth
}
