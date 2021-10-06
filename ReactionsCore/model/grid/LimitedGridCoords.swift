//
// Reactions App
//

import Foundation

public struct LimitedGridCoords {

    public init(
        grid: BeakerGrid,
        initialCoords: [GridCoordinate] = [],
        otherCoords: [GridCoordinate] = [],
        minToAdd: Int,
        maxToAdd: Int
    ) {
        assert(minToAdd <= maxToAdd)
        assert(initialCoords.count < maxToAdd)
        self.grid = grid
        self.coords = initialCoords
        self.otherCoords = otherCoords
        self.minToAdd = minToAdd
        self.maxToAdd = maxToAdd
    }

    public private(set) var coords: [GridCoordinate]
    public let grid: BeakerGrid
    private let otherCoords: [GridCoordinate]
    private let minToAdd: Int
    private let maxToAdd: Int

    public mutating func add(count: Int) {
        let availableToAdd = maxToAdd - coords.count
        let toAdd = min(availableToAdd, count)
        guard toAdd > 0 else {
            return
        }

        coords = GridCoordinateList.addingRandomElementsTo(
            grid: coords,
            count: toAdd,
            cols: grid.cols,
            rows: grid.rows,
            avoiding: otherCoords
        )
    }

    public var hasAddedEnough: Bool {
        coords.count >= minToAdd
    }

    public var canAdd: Bool {
        coords.count < maxToAdd
    }
}
