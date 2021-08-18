//
// Reactions App
//

import CoreGraphics

public struct TableCellPosition {

    private init() { }

    /// Returns the position of the center of the cell at the given row and column index, within the provided table limits.
    public static func position(
        in rect: CGRect,
        rows: Int,
        cols: Int,
        rowIndex row: Int,
        colIndex col: Int
    ) -> CGPoint {
        precondition(rows > 0, "Rows must be positive")
        precondition(cols > 0, "Cols must be positive")
        return rect
            .row(index: row, maxRows: rows)
            .col(index: col, maxCols: cols)
            .center
    }
}

private extension CGRect {
    func row(index: Int, maxRows: Int) -> CGRect {
        precondition(maxRows > 0, "Rows must be positive")
        let rowHeight = height / CGFloat(maxRows)
        let dy = rowHeight * CGFloat(index)
        return CGRect(
            origin: self.origin.offset(dx: 0, dy: dy),
            size: CGSize(width: width, height: rowHeight)
        )
    }

    func col(index: Int, maxCols: Int) -> CGRect {
        precondition(maxCols > 0, "Columns must be positive")
        let colWidth = width / CGFloat(maxCols)
        let dx = colWidth * CGFloat(index)
        return CGRect(
            origin: self.origin.offset(dx: dx, dy: 0),
            size: CGSize(width: colWidth, height: height)
        )
    }
}
