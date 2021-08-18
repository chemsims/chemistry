//
// Reactions App
//

import Foundation
import CoreGraphics
import ReactionsCore

struct BalancedReactionMoleculeLayout {

    init(
        rect: CGRect,
        reactants: BalancedReaction.Side,
        products: BalancedReaction.Side
    ) {
        func pos(row: Int, colIndex: Int, cols: Int) -> CGPoint {
            TableCellPosition.position(in: rect, rows: 2, cols: cols, rowIndex: row, colIndex: colIndex)
        }
        func singleElemPos(row: Int) -> CGPoint {
            pos(row: row, colIndex: 0, cols: 1)
        }
        func doubleElemPos(row: Int, col: Int) -> CGPoint {
            pos(row: row, colIndex: col, cols: 2)
        }

        switch reactants {
        case .single:
            self.firstReactantPosition = singleElemPos(row: 0)
            self.secondReactantPosition = nil
        case .double:
            self.firstReactantPosition = doubleElemPos(row: 0, col: 0)
            self.secondReactantPosition = doubleElemPos(row: 0, col: 1)
        }

        switch products {
        case .single:
            self.firstProductPosition = singleElemPos(row: 1)
            self.secondProductPosition = nil
        case .double:
            self.firstProductPosition = doubleElemPos(row: 1, col: 0)
            self.secondProductPosition = doubleElemPos(row: 1, col: 1)
        }
    }

    let firstReactantPosition: CGPoint

    let secondReactantPosition: CGPoint?

    let firstProductPosition: CGPoint

    let secondProductPosition: CGPoint?
}
