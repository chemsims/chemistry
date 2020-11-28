//
// Reactions App
//
  

import SwiftUI

struct MoleculeGridSettings {
    let totalWidth: CGFloat

    static let rows = 10
    static let cols = 19

    var cellPadding: CGFloat {
        cellSize * 0.05
    }

    var cellSize: CGFloat {
        totalWidth / CGFloat(MoleculeGridSettings.cols)
    }

    var height: CGFloat {
        CGFloat(MoleculeGridSettings.rows) * cellSize
    }

    static func moleculeRadius(width: CGFloat) -> CGFloat {
        let settings = MoleculeGridSettings(totalWidth: width)
        return (settings.cellSize - settings.cellPadding) / 2
    }

    static var fullGrid: [GridCoordinate] {
        (0..<cols).flatMap { c in
            (0..<rows).map { r in
                GridCoordinate(col: c, row: r)
            }
        }
    }
}
