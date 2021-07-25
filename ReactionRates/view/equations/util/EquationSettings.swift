//
// Reactions App
//

import CoreGraphics

struct EquationSettings {
    static let hSpacing: CGFloat = 2
    static let boxHeight: CGFloat = 50
    static let boxWidth: CGFloat = 70

    static let boxPadding: CGFloat = 10

    static let fontSize: CGFloat = 30
    static let subscriptFontSize: CGFloat = 22

    private static let orderStringSpacing: CGFloat = 10
    private static let orderStringWidth: CGFloat = 112
    private static let orderStringHeight: CGFloat = 35

    private static let zeroOrderWidth: CGFloat = 224
    private static let zeroOrderHeight: CGFloat = 81

    static let zeroOrderTotalWidth = totalWidth(equationWidth: zeroOrderWidth)
    static let zeroOrderTotalHeight = totalHeight(equationHeight: zeroOrderHeight)

    static func totalWidth(equationWidth: CGFloat) -> CGFloat {
        orderStringWidth + orderStringSpacing + equationWidth
    }

    static func totalHeight(equationHeight: CGFloat) -> CGFloat {
        max(equationHeight, orderStringHeight)
    }
}
