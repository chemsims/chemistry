//
// Reactions App
//

import ReactionsCore
import XCTest

class BeakerGridRandomGrowthTests: XCTestCase {

    func testThatTheDefaultCenterIsInTheMiddleOfAnOddGrid() {
        let grid = getList(cols: 3, rows: 3, count: 1)
        XCTAssertEqual(grid, [.init(col: 1, row: 1)])
    }

    func testFillingASquare() {
        let grid = getList(cols: 2, rows: 2, count: 4)
        let expected = [
            (0,0), (0, 1), (1, 0), (1, 1)
        ].map(makeCoord)

        XCTAssertEqual(Set(grid), Set(expected))
    }

    func testFillingARectangle() {
        let grid = getList(cols: 4, rows: 2, count: 8)
        let expected = [
            (0,0), (1, 0), (2, 0), (3, 0),
            (0,1), (1, 1), (2, 1), (3, 1)
        ].map(makeCoord)

        XCTAssertEqual(Set(grid), Set(expected))
    }

    func testAddingAnElementToAnExplicitCenter() {
        let center = GridCoordinate(col: 4, row: 4)
        let grid = getList(
            cols: 5,
            rows: 5,
            count: 1,
            existing: [center]
        )
        XCTAssertEqual(grid.count, 2)
        XCTAssertEqual(grid[0], center)

        if grid[1].col == 4 {
            XCTAssertEqual(grid[1].row, 3)
        } else if grid[1].row == 4 {
            XCTAssertEqual(grid[1].col, 3)
        } else {
            XCTAssertEqual(grid[1].row, 3)
            XCTAssertEqual(grid[1].col, 3)
        }
    }

    func testReturningEarlyWhenTheGridCantGrowAnyMore() {
        let grid = getList(cols: 3, rows: 3, count: 20)
        let expected = (0..<3).flatMap { col in
            (0..<3).map { row in
                GridCoordinate(col: col, row: row)
            }
        }
        XCTAssertEqual(Set(grid), Set(expected))
    }

    func testGrowingExistingCoordinatesIntoASquare() {
        let existing = [(2, 1), (1, 2)].map(makeCoord)
        let grid = getList(
            cols: 5,
            rows: 5,
            count: 2,
            existing: existing
        )

        XCTAssertEqual(Array(grid.prefix(2)), existing)

        let expectedLatter = [(1, 1), (2, 2)].map(makeCoord)
        XCTAssertEqual(Set(grid.dropFirst(2)), Set(expectedLatter))
    }

    private func getList(
        cols: Int,
        rows: Int,
        count: Int,
        existing: [GridCoordinate] = []
    ) -> [GridCoordinate] {
        GridCoordinateList.randomGrowth(
            cols: cols,
            rows: rows,
            count: count,
            existing: existing
        )
    }

    private func makeCoord(_ tuple: (Int, Int)) -> GridCoordinate {
        GridCoordinate(col: tuple.0, row: tuple.1)
    }
}
