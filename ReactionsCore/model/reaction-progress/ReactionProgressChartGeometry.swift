//
// Reactions App
//

import CoreGraphics

public struct ReactionProgressChartGeometry<MoleculeType: CaseIterable> {

    // TODO - in hindsight passing in `MoleculeType.Type` was not a good idea
    // just to get the molecule count.
    public init(
        chartSize: CGFloat,
        moleculeType: MoleculeType.Type,
        maxMolecules: Int = 10,
        topPadding: CGFloat
    ) {
        let colCount = moleculeType.allCases.count
        assert(colCount > 0)
        assert(maxMolecules > 0)
        let maxMoleculeFloat = CGFloat(maxMolecules)
        let moleculeSizeForWidth = chartSize / maxMoleculeFloat
        let availableHeight = chartSize - topPadding

        let moleculeSizeForHeight = availableHeight / maxMoleculeFloat

        self.chartSize = chartSize
        let moleculeSize = min(moleculeSizeForHeight, moleculeSizeForWidth)
        self.moleculeSize = moleculeSize

        let dxColumn = chartSize / (2 * CGFloat(colCount))
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

        let barGeometry = BarChartGeometry(chartWidth: chartSize, minYValue: 0, maxYValue: 1)
        self.axisLineWidth = barGeometry.axisLineWidth
        self.chartToAxisSpacing = barGeometry.chartToAxisSpacing
        self.axisLayout = barGeometry.axisLayout
    }

    // Diameter of a molecule
    let moleculeSize: CGFloat

    // Length of each side of the chart
    let chartSize: CGFloat

    let axisLineWidth: CGFloat
    let chartToAxisSpacing: CGFloat
    public let axisLayout: CircleChartLabel.Layout

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
}
