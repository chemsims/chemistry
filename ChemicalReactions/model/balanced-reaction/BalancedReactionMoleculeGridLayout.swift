//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct BalancedReactionMoleculeGridLayout {

    init(
        rect: CGRect,
        reactants: BalancedReaction.ElementCount,
        products: BalancedReaction.ElementCount
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
        case .one:
            self.firstReactantPosition = singleElemPos(row: 0)
            self.secondReactantPosition = nil
        case .two:
            self.firstReactantPosition = doubleElemPos(row: 0, col: 0)
            self.secondReactantPosition = doubleElemPos(row: 0, col: 1)
        }

        switch products {
        case .one:
            self.firstProductPosition = singleElemPos(row: 1)
            self.secondProductPosition = nil
        case .two:
            self.firstProductPosition = doubleElemPos(row: 1, col: 0)
            self.secondProductPosition = doubleElemPos(row: 1, col: 1)
        }
    }

    func position(
        substanceType: BalancedReaction.ElementType,
        side: BalancedReaction.ElementOrder
    ) -> CGPoint? {
        switch (substanceType, side) {
        case (.reactant, .first): return firstReactantPosition
        case (.reactant, .second): return secondReactantPosition
        case (.product, .first): return firstProductPosition
        case (.product, .second): return secondProductPosition
        }
    }

    let firstReactantPosition: CGPoint

    let secondReactantPosition: CGPoint?

    let firstProductPosition: CGPoint

    let secondProductPosition: CGPoint?
}
