//
// ReactionsCore
//

import Foundation

/// Represents a position in a grid
public struct GridCoordinate: Identifiable {

    /// Column index - starts at zero
    public let col: Int

    /// Row index - starts at zero
    public let row: Int

    public var id: String {
        "\(col),\(row)"
    }

    public static func random(maxCol: Int, maxRow: Int) -> GridCoordinate {
        GridCoordinate(col: Int.random(in: 0...maxCol), row: Int.random(in: 0...maxRow))
    }
}
