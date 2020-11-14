//
// Reactions App
//
  

import Foundation

/// Represents a position in a grid
struct GridCoordinate: Identifiable {

    /// Column index - starts at zero
    let col: Int

    /// Row index - starts at zero
    let row: Int

    var id: String {
        "\(col),\(row)"
    }

    static func random(maxCol: Int, maxRow: Int) -> GridCoordinate {
        GridCoordinate(col: Int.random(in: 0...maxCol), row: Int.random(in: 0...maxRow))
    }
}

