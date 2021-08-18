//
// Reactions App
//

import Foundation
import CoreGraphics

struct BalancedReactionMoleculeLayout {

    init(
        rect: CGRect,
        reactants: BalancedReaction.Side,
        products: BalancedReaction.Side
    ) {
        let topRowRect = CGRect(
            origin: rect.origin,
            size: CGSize(width: rect.width, height: rect.height / 2)
        )
        let bottomRowRect = topRowRect.offsetBy(dx: 0, dy: rect.height / 2)

        self.reactantLayout = .init(rowRect: topRowRect, side: reactants)
        self.productLayout = .init(rowRect: bottomRowRect, side: products)
    }

    private let reactantLayout: BalancedReactionMoleculeLayout.SideLayout
    private let productLayout: BalancedReactionMoleculeLayout.SideLayout

    var firstReactantPosition: CGPoint {
        reactantLayout.firstPosition
    }

    var secondReactantPosition: CGPoint? {
        reactantLayout.secondPosition
    }

    var firstProductPosition: CGPoint {
        productLayout.firstPosition
    }

    var secondProductPosition: CGPoint? {
        productLayout.secondPosition
    }
}

private extension BalancedReactionMoleculeLayout {
    struct SideLayout {
        let rowRect: CGRect
        let side: BalancedReaction.Side

        var firstPosition: CGPoint {
            switch side {
            case .single:
                return SingleElementPositionInRow.position(in: rowRect)

            case .double:
                return DoubleElementPositionInRow.firstPosition(in: rowRect)
            }
        }

        var secondPosition: CGPoint? {
            switch side {
            case .single: return nil

            case .double:
                return DoubleElementPositionInRow.secondPosition(in: rowRect)
            }
        }
    }
}

private struct SingleElementPositionInRow {
    private init() { }

    static func position(in rect: CGRect) -> CGPoint {
        let x = rect.minX + (rect.width / 2)
        let y = rect.minY + (rect.height / 2)
        return CGPoint(x: x, y: y)
    }
}

private struct DoubleElementPositionInRow {
    private init() { }

    static func firstPosition(in rect: CGRect) -> CGPoint {
        let x = rect.origin.x + (rect.width / 4)
        let y = rect.origin.y + (rect.height / 2)
        return CGPoint(x: x, y: y)
    }

    static func secondPosition(in rect: CGRect) -> CGPoint {
        firstPosition(in: rect).offset(dx: rect.width / 2, dy: 0)
    }
}
