//
// Reactions App
//


import XCTest
@testable import ReactionsCore

class GridCoordinateListTests: XCTestCase {

    func testMakingAListOfCoords() {
        let result = GridCoordinateList.list(cols: 2, rows: 2)
        let expected = [
            GridCoordinate(col: 0, row: 0),
            GridCoordinate(col: 1, row: 0),
            GridCoordinate(col: 0, row: 1),
            GridCoordinate(col: 1, row: 1),
        ]
        XCTAssertEqual(result, expected)
    }

    func testAddingASingleGridElement() {
        let grid = [GridCoordinate]()
        let result = GridCoordinateList.addingRandomElementsTo(
            grid: grid,
            count: 1,
            cols: 1,
            rows: 1
        )
        XCTAssertEqual(result, [GridCoordinate(col: 0, row: 0)])
    }

    func testAddingASingleElementToAGridWithOnlyOneSpot() {
        let coord1 = GridCoordinate(col: 0, row: 0)
        let coord2 = GridCoordinate(col: 1, row: 0)
        let result = GridCoordinateList.addingRandomElementsTo(
            grid: [coord1, coord2],
            count: 1,
            cols: 3,
            rows: 1
        )
        XCTAssertEqual(result, [coord1, coord2, GridCoordinate(col: 2, row: 0)])
    }

    func testAddingAnElementToAFullGrid() {
        let coord = GridCoordinate(col: 0, row: 0)
        let result = GridCoordinateList.addingRandomElementsTo(
            grid: [coord],
            count: 1,
            cols: 1,
            rows: 1
        )
        XCTAssertEqual(result, [coord])
    }

    func testAddingMultipleElementsToAGrid() {
        let result = GridCoordinateList.addingRandomElementsTo(
            grid: [],
            count: 10,
            cols: 2,
            rows: 2
        )
        let expectedCoords = GridCoordinateList.list(cols: 2, rows: 2)
        expectedCoords.forEach { coord in
            XCTAssertEqual(result.filter { $0 == coord}, [coord])
        }
    }

    func testAddingAnElementToAGridWhileAvoidingAnotherGrid() {
        let result = GridCoordinateList.addingRandomElementsTo(
            grid: [],
            count: 1,
            cols: 2,
            rows: 1,
            avoiding: [GridCoordinate(col: 0, row: 0)]
        )
        XCTAssertEqual(result, [GridCoordinate(col: 1, row: 0)])
    }

    func testTheFunctionReturningWhenThereAreTooManyElementsInAvoidingAndGrid() {
        let grid = [GridCoordinate(col: 0, row: 0)]
        let avoiding = [GridCoordinate(col: 1, row: 0)]
        let result = GridCoordinateList.addingRandomElementsTo(
            grid: grid,
            count: 1,
            cols: 2,
            rows: 1,
            avoiding: avoiding
        )
        XCTAssertEqual(result, grid)
    }

    /// Since new elements are generated randomly, all tests are run multiple times to avoid flaky tests
    override func invokeTest() {
        (0...5).forEach { _ in
            super.invokeTest()
        }
    }

}
