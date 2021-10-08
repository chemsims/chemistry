//
// ReactionsCore
//

import CoreGraphics

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

    /// Returns an integer number of rows available for the given fraction of rows visible
    public static func availableRows(for rows: CGFloat) -> Int {
        if rows - rows.rounded(.down) > 0.4 {
            return Int(ceil(rows))
        }
        return Int(rows)
    }

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
            if (remaining <= 0 || Set(builder + avoiding).count >= (cols * rows)) {
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

    public static func addingElementsTo(
        grid: [GridCoordinate],
        count: Int,
        from: [GridCoordinate],
        avoiding: [GridCoordinate]
    ) -> [GridCoordinate] {
        let available = from.filter { !avoiding.contains($0) && !grid.contains($0) }
        return grid + Array(available.prefix(count))
    }

    /// Returns a list of all `GridCoordinate` up to the provided `cols` and `rows`
    public static func list(cols: Int, rows: Int) -> [GridCoordinate] {
        (0..<rows).flatMap { row in
            (0..<cols).map { col in
                GridCoordinate(col: col, row: row)
            }
        }
    }

    /// Returns a list of coordinates which grow in a clockwise spiral
    /// from the center of the grid
    public static func spiralGrid(cols: Int, rows: Int, count: Int) -> [GridCoordinate] {
        GridSpiralModel.spiralGrid(
            cols: cols,
            rows: rows,
            count: count
        )
    }

    /// Returns a list of coordinates which grows outside in a random pattern.
    /// Each coordinate is adjacent or diagonal to an existing coordinate.
    /// The coordinates grow evenly away from the center. i.e., if we a single
    /// row, then we'd always have at most one more or less coordinate on the
    /// left than we do on the right - instead of say growing bigger in
    /// one direction.
    ///
    /// - Parameters:
    ///   - count: Total count of coordinates, including the center one.
    ///   - center: The center coordinate of the growth. If none is
    ///   provided, the center of the grid is used.
    public static func randomGrowth(
        cols: Int,
        rows: Int,
        count: Int,
        center: GridCoordinate? = nil
    ) -> [GridCoordinate] {
        RandomGrowthModel.randomGrowth(
            cols: cols,
            rows: rows,
            count: count,
            center: center
        )
    }

}

fileprivate struct GridSpiralModel {

    static func spiralGrid(cols: Int, rows: Int, count: Int) -> [GridCoordinate] {
        guard count > 0 else {
            return []
        }

        var minCol = cols / 2
        var maxCol = minCol
        var minRow = rows / 2
        var maxRow = minRow

        var col = minCol
        var row = minRow

        var direction = Direction.left
        var result = [GridCoordinate]()

        var failedExtensionDirections = Set<Direction>()

        for _ in 0..<count {
            let validCol = col >= 0 && col < cols
            let validRow = row >= 0 && row < rows
            if validCol && validRow {
                let nextCoord = GridCoordinate(col: col, row: row)
                result.append(nextCoord)
            } else {
                break
            }

            switch direction {
            // hit left bounds
            case .left where col == 0 && col == minCol:
                failedExtensionDirections.insert(.left)
                direction = .up
                row = minRow - 1

            // hit top bounds
            case .up where row == 0 && row == minRow:
                failedExtensionDirections.insert(.up)
                direction = .right
                col = maxCol + 1

            // hit right bounds
            case .right where col == cols - 1 && col == maxCol:
                failedExtensionDirections.insert(.right)
                direction = .down
                row = maxRow + 1

            // hit bottom bounds
            case .down where row == rows - 1 && row == maxRow:
                failedExtensionDirections.insert(.down)
                direction = .left
                col = minCol - 1

            // Extend left
            case .left where col < minCol:
                minCol = col
                direction = .up
                row -= 1

            // Extend top
            case .up where row < minRow:
                minRow = row
                direction = .right
                col += 1

            // Extend right
            case .right where col > maxCol:
                maxCol = col
                direction = .down
                row += 1

            // Extend down
            case .down where row > maxRow:
                maxRow = row
                direction = .left
                col -= 1

            // continue in same direction
            default:
                row += direction.rowDelta
                col += direction.colDelta
            }


        }
        return result
    }

    enum Direction {
        case left, up, right, down

        var colDelta: Int {
            switch self {
            case .left: return -1
            case .right: return 1
            case .up, .down: return 0
            }
        }

        var rowDelta: Int {
            switch self {
            case .up: return -1
            case .down: return 1
            case .left, .right: return 0
            }
        }
    }
}

fileprivate struct RandomGrowthModel {

    let cols: Int
    let rows: Int

    static func randomGrowth(
        cols: Int,
        rows: Int,
        count: Int,
        center centerOpt: GridCoordinate?
    ) -> [GridCoordinate] {
        guard count > 0 else {
            return []
        }

        let center = centerOpt ?? .init(col: cols / 2, row: rows / 2)

        return randomlyGrow(
            cols: cols,
            rows: rows,
            result: [center],
            remainingCount: count - 1,
            minRow: center.row,
            maxRow: center.row,
            minCol: center.col,
            maxCol: center.col
        )
    }

    /// The approach here is we expand the min/max row/col outwards,
    /// and then append shuffled coords from the expanded area. If
    /// we have no more coordinates to add or if we cannot expand
    /// any further, then we return the result.
    private static func randomlyGrow(
        cols: Int,
        rows: Int,
        result: [GridCoordinate],
        remainingCount: Int,
        minRow: Int,
        maxRow: Int,
        minCol: Int,
        maxCol: Int
    ) -> [GridCoordinate] {
        if remainingCount <= 0 {
            return result
        }
        let hasPreviousRow = minRow > 0
        let hasNextRow = maxRow < rows - 1
        let hasPreviousCol = minCol > 0
        let hasNextCol = maxCol < cols - 1

        var nextCoords = [GridCoordinate]()

        var nextMinCol = minCol
        if hasPreviousCol {
            nextMinCol = minCol - 1
            (minRow...maxRow).forEach { row in
                let coord = GridCoordinate(col: minCol - 1, row: row)
                nextCoords.append(coord)
            }
        }

        var nextMaxCol = maxCol
        if hasNextCol {
            nextMaxCol = maxCol + 1
            (minRow...maxRow).forEach { row in
                let coord = GridCoordinate(col: maxCol + 1, row: row)
                nextCoords.append(coord)
            }
        }

        var nextMinRow = minRow
        if hasPreviousRow {
            nextMinRow = minRow - 1
            (nextMinCol...nextMaxCol).forEach { col in
                let coord = GridCoordinate(col: col, row: minRow - 1)
                nextCoords.append(coord)
            }
        }

        var nextMaxRow = maxRow
        if hasNextRow {
            nextMaxRow = maxRow + 1
            (nextMinCol...nextMaxCol).forEach { col in
                let coord = GridCoordinate(col: col, row: maxRow + 1)
                nextCoords.append(coord)
            }
        }

        nextCoords = Array(nextCoords.shuffled().prefix(remainingCount))


        if nextCoords.isEmpty {
            return result
        }
        return randomlyGrow(
            cols: cols,
            rows: rows,
            result: result + nextCoords,
            remainingCount: remainingCount - nextCoords.count,
            minRow: nextMinRow,
            maxRow: nextMaxRow,
            minCol: nextMinCol,
            maxCol: nextMaxCol
        )
    }
}
