//
// ReactionsCore
//

import SwiftUI

public struct MoleculeGridSettings {
    public let totalWidth: CGFloat

    public static let rows = 10
    public static let cols = 19

    public var cellPadding: CGFloat {
        cellSize * 0.05
    }

    public var cellSize: CGFloat {
        totalWidth / CGFloat(MoleculeGridSettings.cols)
    }

    func height(for rows: CGFloat) -> CGFloat {
        rows * cellSize
    }

    public static func moleculeRadius(width: CGFloat) -> CGFloat {
        let settings = MoleculeGridSettings(totalWidth: width)
        return (settings.cellSize - settings.cellPadding) / 2
    }

    public static var fullGrid: [GridCoordinate] {
        grid(rows: rows)
    }

    public static func grid(rows: Int) -> [GridCoordinate] {
        (0..<cols).flatMap { c in
            (0..<rows).map { r in
                GridCoordinate(col: c, row: r)
            }
        }
    }
}
