//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class GridElementSetterTests: XCTestCase {

    func testSettingOneIncreasingElement() {
        let grid = GridCoordinate.grid(cols: 1, rows: 10)
        let model = GridElementSetter.init(
            elements: [
                GridElementToBalance(
                    initialCoords: Array(grid.prefix(1)),
                    finalCount: 2
                )
            ],
            shuffledCoords: grid
        )
        XCTAssertEqual(
            model.balancedElements, [
                BalancedGridElement(
                    coords: Array(grid.prefix(2)),
                    initialFraction: 0.5, finalFraction: 1
                )
            ]
        )
    }

    func testSettingOneDecreasingElement() {
        let grid = GridCoordinate.grid(cols: 1, rows: 10)
        let model = GridElementSetter.init(
            elements: [
                GridElementToBalance(
                    initialCoords: Array(grid.prefix(2)),
                    finalCount: 1
                )
            ],
            shuffledCoords: grid
        )
        XCTAssertEqual(
            model.balancedElements, [
                BalancedGridElement(
                    coords: Array(grid.prefix(2)),
                    initialFraction: 1, finalFraction: 0.5
                )
            ]
        )
    }

    func testSettingTwoIncreasingElements() {
        let grid = GridCoordinate.grid(cols: 1, rows: 10)
        let model = GridElementSetter.init(
            elements: [
                GridElementToBalance(initialCoords: Array(grid[0..<2]), finalCount: 4),
                GridElementToBalance(initialCoords: Array(grid[2..<4]), finalCount: 4),
            ],
            shuffledCoords: grid
        )
        let expectedA = BalancedGridElement(
            coords: Array(grid[0..<2] + grid[4..<6]),
            initialFraction: 0.5,
            finalFraction: 1
        )
        let expectedB = BalancedGridElement(
            coords: Array(grid[2..<4] + grid[6..<8]),
            initialFraction: 0.5,
            finalFraction: 1
        )
        XCTAssertEqual(model.balancedElements, [expectedA, expectedB])
    }

    func testSettingTwoDecreasingElements() {
        let grid = GridCoordinate.grid(cols: 1, rows: 10)
        let model = GridElementSetter.init(
            elements: [
                GridElementToBalance(initialCoords: Array(grid[0..<4]), finalCount: 1),
                GridElementToBalance(initialCoords: Array(grid[4..<8]), finalCount: 1),
            ],
            shuffledCoords: grid
        )
        let expectedA = BalancedGridElement(
            coords: Array(grid[0..<4]),
            initialFraction: 1,
            finalFraction: 0.25
        )
        let expectedB = BalancedGridElement(
            coords: Array(grid[4..<8]),
            initialFraction: 1,
            finalFraction: 0.25
        )
        XCTAssertEqual(model.balancedElements, [expectedA, expectedB])
    }
}
