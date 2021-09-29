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

    public static func spiralGrid(cols: Int, rows: Int, count: Int) -> [GridCoordinate] {
        GridSpiralModel.spiralGrid(
            cols: cols,
            rows: rows,
            count: count
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
