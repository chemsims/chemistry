//
// ReactionsCore
//

import SwiftUI

public struct MoleculeGridSettings {
    public let totalWidth: CGFloat

    public init(totalWidth: CGFloat) {
        self.totalWidth = totalWidth
    }

    public static let rows = 10
    public static let cols = 19

    public var cellPadding: CGFloat {
        cellSize * 0.05
    }

    public var cellSize: CGFloat {
        totalWidth / CGFloat(MoleculeGridSettings.cols)
    }

    public func height(for rows: CGFloat) -> CGFloat {
        rows * cellSize
    }

    public static func moleculeRadius(width: CGFloat) -> CGFloat {
        let settings = MoleculeGridSettings(totalWidth: width)
        return (settings.cellSize - settings.cellPadding) / 2
    }

    public static let fullGrid = grid(rows: rows)

    public static func grid(rows: Int) -> [GridCoordinate] {
        GridCoordinate.grid(cols: cols, rows: rows)
    }
}
