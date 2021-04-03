//
// Reactions App
//


import SwiftUI

public struct AnimatingMoleculeGridShape: Shape {
    /// Dimension of a single cell
    let cellSize: CGFloat

    /// How much padding to place in the cell before drawing the molecule
    let cellPadding: CGFloat

    /// Whether the grid should start from the top or bottom
    let drawFromTop: Bool

    /// The coordinates to draw
    let coords: [GridCoordinate]

    let fractionOfCoordsToDraw: Equation

    var currentTime: CGFloat

    public init(
        cellSize: CGFloat,
        cellPadding: CGFloat,
        drawFromTop: Bool,
        coords: [GridCoordinate],
        fractionOfCoordsToDraw: Equation,
        currentTime: CGFloat
    ) {
        self.cellSize = cellSize
        self.cellPadding = cellPadding
        self.drawFromTop = drawFromTop
        self.coords = coords
        self.fractionOfCoordsToDraw = fractionOfCoordsToDraw
        self.currentTime = currentTime
    }

    public var animatableData: CGFloat {
        get { currentTime }
        set { currentTime = newValue }
    }

    public func path(in rect: CGRect) -> Path {
        let fraction = fractionOfCoordsToDraw.getY(at: currentTime)
        var coordsToDraw = (fraction * CGFloat(coords.count)).roundedInt()
        if coordsToDraw < 0 {
            coordsToDraw = 0
        }

        return MoleculeGridShape(
            cellSize: cellSize,
            cellPadding: cellPadding,
            drawFromTop: drawFromTop,
            coords: Array(coords.prefix(coordsToDraw))
        ).path(in: rect)
    }
}

/// A grid of molecules.
/// The shape does not attempt to force the circles into the entire frame.
/// Instead, the molecules are simply based based on the provided size properties
/// The frame itself should be sized correctly to fit all the molecules.
public struct MoleculeGridShape: Shape {

    /// Dimension of a single cell
    let cellSize: CGFloat

    /// How much padding to place in the cell before drawing the molecule
    let cellPadding: CGFloat

    /// The coordinates to draw
    let coords: [GridCoordinate]

    let drawFromTop: Bool

    public init(
        cellSize: CGFloat,
        cellPadding: CGFloat,
        drawFromTop: Bool,
        coords: [GridCoordinate]
    ) {
        self.cellSize = cellSize
        self.cellPadding = cellPadding
        self.drawFromTop = drawFromTop
        self.coords = coords
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        for coord in coords {
            let x = cellSize * CGFloat(coord.col)
            let y = getY(for: coord.row, rectHeight: rect.height)

            let xPadded = x + cellPadding
            let yPadded = y + cellPadding
            let size = cellSize - (2 * cellPadding)
            let rect = CGRect(x: xPadded, y: yPadded, width: size, height: size)
            path.addEllipse(in: rect)
        }
        return path
    }

    private func getY(for rowIndex: Int, rectHeight: CGFloat) -> CGFloat {
        if drawFromTop {
            return cellSize * CGFloat(rowIndex)
        } else {
            return rectHeight - (cellSize * CGFloat(rowIndex + 1))
        }
    }

}
