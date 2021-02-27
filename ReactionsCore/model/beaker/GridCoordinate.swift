//
// ReactionsCore
//

import Foundation

/// Represents a position in a grid
public struct GridCoordinate: Identifiable, Equatable, Hashable {

    /// Column index - starts at zero
    public let col: Int

    /// Row index - starts at zero
    public let row: Int

    public init(col: Int, row: Int) {
        self.col = col
        self.row = row
    }

    public var id: String {
        "\(col),\(row)"
    }

    public static func random(maxCol: Int, maxRow: Int) -> GridCoordinate {
        GridCoordinate(col: Int.random(in: 0...maxCol), row: Int.random(in: 0...maxRow))
    }

    public static func grid(cols: Int, rows: Int) -> [GridCoordinate] {
        (0..<cols).flatMap { c in
            (0..<rows).map { r in
                GridCoordinate(col: c, row: r)
            }
        }
    }
}

public struct GridCoordinateList {

    /// Adds `count` random elements to `grid`, returning a new grid
    public static func addingRandomElementsTo(
        grid: [GridCoordinate],
        count: Int,
        cols: Int,
        rows: Int,
        avoiding: [GridCoordinate] = []
    ) -> [GridCoordinate] {

        var builder = grid

        func add(_ remaining: Int) {
            if (remaining == 0 || Set(builder + avoiding).count >= (cols * rows)) {
                return
            }
            let coord = GridCoordinate.random(maxCol: cols - 1, maxRow: rows - 1)
            if builder.contains(coord) || avoiding.contains(coord) {
                add(remaining)
            } else {
                builder.append(coord)
                add(remaining - 1)
            }
        }
        add(count)
        return builder
    }

    /// Returns a list of all `GridCoordinate` up to the provided `cols` and `rows`
    public static func list(cols: Int, rows: Int) -> [GridCoordinate] {
        (0..<rows).flatMap { row in
            (0..<cols).map { col in
                GridCoordinate(col: col, row: row)
            }
        }
    }
}
