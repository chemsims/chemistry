//
// Reactions App
//

import CoreGraphics

struct ReactionProgressChartGeometry {

    init(
        chartSize: CGFloat,
        colCount: Int,
        maxMolecules: Int,
        topPadding: CGFloat
    ) {
        assert(colCount > 0)
        assert(maxMolecules > 0)
        let maxMoleculeFloat = CGFloat(maxMolecules)
        let moleculeSizeForWidth = chartSize / maxMoleculeFloat
        let availableHeight = chartSize - topPadding

        let moleculeSizeForHeight = availableHeight / maxMoleculeFloat

        self.moleculeSize = min(moleculeSizeForHeight, moleculeSizeForWidth)

        let dxColumn = chartSize / CGFloat(colCount + 1)
        self.columnXEquation = LinearEquation(
            x1: 0,
            y1: dxColumn,
            x2: CGFloat(colCount - 1),
            y2: chartSize - dxColumn
        )

        self.rowYEquation = LinearEquation(
            x1: 0,
            y1: chartSize - (moleculeSize / 2),
            x2: CGFloat(maxMolecules - 1),
            y2: topPadding + (moleculeSize / 2)
        )
        self.maxRowIndex = maxMolecules - 1
    }

    // Diameter of a molecule
    let moleculeSize: CGFloat

    let maxRowIndex: Int

    private let columnXEquation: Equation
    private let rowYEquation: Equation


    /// Returns position of a molecule at the given `colIndex` and `rowIndex`
    ///
    /// - Parameters:
    ///     - colIndex: Index of the column, starting at 0 for the left most column
    ///     - rowIndex: Index of the row, starting at 0 for the bottom most row
    func position(
        colIndex: Int,
        rowIndex: Int
    ) -> CGPoint {
        CGPoint(
            x: columnXEquation.getY(at: CGFloat(colIndex)),
            y: rowYEquation.getY(at: CGFloat(rowIndex))
        )
    }

    /// Returns the time to move from the starting to a final row, with the given drop speed
    func moveDuration(
        from startRowIndex: Int,
        to endRowIndex: Int,
        dropSpeed: Double
    ) -> TimeInterval {
        let startY = rowYEquation.getY(at: CGFloat(startRowIndex))
        let endY = rowYEquation.getY(at: CGFloat(endRowIndex))
        let dy = Double(abs(endY - startY))

        return dy == 0 ? 0 : dy / dropSpeed
    }
}
