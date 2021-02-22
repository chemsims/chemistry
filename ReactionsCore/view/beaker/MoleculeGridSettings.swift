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

    public var height: CGFloat {
        CGFloat(MoleculeGridSettings.rows) * cellSize
    }

    public static func moleculeRadius(width: CGFloat) -> CGFloat {
        let settings = MoleculeGridSettings(totalWidth: width)
        return (settings.cellSize - settings.cellPadding) / 2
    }

    public static var fullGrid: [GridCoordinate] {
        (0..<cols).flatMap { c in
            (0..<rows).map { r in
                GridCoordinate(col: c, row: r)
            }
        }
    }
}
