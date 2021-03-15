//
// Reactions App
//


import XCTest
@testable import ReactionsCore

class GridElementBalancerTests: XCTestCase {

    func testReducingElementsAreTransferredToIncreasingElementsProportionally() throws {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let model = GridElementBalancer(
            initialIncreasingA: GridElementToBalance(
                initialCoords: [],
                finalCount: 10
            ),
            initialIncreasingB: GridElementToBalance(
                initialCoords: [],
                finalCount: 10
            ),
            initialReducingC: GridElementToBalance(
                initialCoords: Array(grid[0..<20]),
                finalCount: 10
            ),
            initialReducingD: GridElementToBalance(
                initialCoords: Array(grid[20..<40]),
                finalCount: 10
            ),
            grid: grid
        )

        XCTAssertEqual(model.balancedA.coords, Array(grid[0..<5] + grid[20..<25]))
        XCTAssertEqual(model.balancedA.initialFraction, 0)
        XCTAssertEqual(model.balancedA.finalFraction, 1)

        XCTAssertEqual(model.balancedB.coords, Array(grid[5..<10] + grid[25..<30]))
        XCTAssertEqual(model.balancedB.initialFraction, 0)
        XCTAssertEqual(model.balancedB.finalFraction, 1)

        XCTAssertEqual(model.balancedC.coords, model.initialReducingC.initialCoords)
        XCTAssertEqual(model.balancedC.initialFraction, 1)
        XCTAssertEqual(model.balancedC.finalFraction, 0.5)

        XCTAssertEqual(model.balancedD.coords, model.initialReducingD.initialCoords)
        XCTAssertEqual(model.balancedD.initialFraction, 1)
        XCTAssertEqual(model.balancedD.finalFraction, 0.5)
    }

    func testReducingElementsAreTransferredToIncreasedElementsWithDifferentProportions() {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let model = GridElementBalancer(
            initialIncreasingA: GridElementToBalance(
                initialCoords: [],
                finalCount: 10
            ),
            initialIncreasingB: GridElementToBalance(
                initialCoords: [],
                finalCount: 10
            ),
            initialReducingC: GridElementToBalance(
                initialCoords: Array(grid[0..<30]),
                finalCount: 15
            ),
            initialReducingD: GridElementToBalance(
                initialCoords: Array(grid[30..<60]),
                finalCount: 25
            ),
            grid: grid
        )

        XCTAssertEqual(model.balancedA.coords, Array(grid[0..<8] + grid[30..<32]))
        XCTAssertEqual(model.balancedA.initialFraction, 0)
        XCTAssertEqual(model.balancedA.finalFraction, 1)

        XCTAssertEqual(model.balancedB.coords, Array(grid[8..<15] + grid[32..<35]))
        XCTAssertEqual(model.balancedB.initialFraction, 0)
        XCTAssertEqual(model.balancedB.finalFraction, 1)

        XCTAssertEqual(model.balancedC.coords, model.initialReducingC.initialCoords)
        XCTAssertEqual(model.balancedC.initialFraction, 1)
        XCTAssertEqual(model.balancedC.finalFraction, 0.5)

        XCTAssertEqual(model.balancedD.coords, model.initialReducingD.initialCoords)
        XCTAssertEqual(model.balancedD.initialFraction, 1)
        XCTAssertEqual(model.balancedD.finalFraction, 0.833, accuracy: 0.001)
    }

    func testOverallReductionInNumberOfElements() {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let model = GridElementBalancer(
            initialIncreasingA: GridElementToBalance(
                initialCoords: [],
                finalCount: 10
            ),
            initialIncreasingB: GridElementToBalance(
                initialCoords: [],
                finalCount: 10
            ),
            initialReducingC: GridElementToBalance(
                initialCoords: Array(grid[0..<30]),
                finalCount: 15
            ),
            initialReducingD: GridElementToBalance(
                initialCoords: Array(grid[30..<60]),
                finalCount: 15
            ),
            grid: grid
        )

        XCTAssertEqual(model.balancedA.coords, Array(grid[0..<5] + grid[30..<35]))
        XCTAssertEqual(model.balancedA.initialFraction, 0)
        XCTAssertEqual(model.balancedA.finalFraction, 1)

        XCTAssertEqual(model.balancedB.coords, Array(grid[5..<10] + grid[35..<40]))
        XCTAssertEqual(model.balancedB.initialFraction, 0)
        XCTAssertEqual(model.balancedB.finalFraction, 1)

        XCTAssertEqual(model.balancedC.coords, model.initialReducingC.initialCoords)
        XCTAssertEqual(model.balancedC.initialFraction, 1)
        XCTAssertEqual(model.balancedC.finalFraction, 0.5)

        XCTAssertEqual(model.balancedD.coords, model.initialReducingD.initialCoords)
        XCTAssertEqual(model.balancedD.initialFraction, 1)
        XCTAssertEqual(model.balancedD.finalFraction, 0.5)
    }

    func testOverallIncreaseInElements() {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let model = GridElementBalancer(
            initialIncreasingA: GridElementToBalance(
                initialCoords: [],
                finalCount: 10
            ),
            initialIncreasingB: GridElementToBalance(
                initialCoords: [],
                finalCount: 10
            ),
            initialReducingC: GridElementToBalance(
                initialCoords: Array(grid[0..<10]),
                finalCount: 5
            ),
            initialReducingD: GridElementToBalance(
                initialCoords: Array(grid[10..<20]),
                finalCount: 5
            ),
            grid: grid
        )

        XCTAssertEqual(model.balancedA.coords, Array(grid[0..<3] + grid[10..<12] + grid[20..<25]))
        XCTAssertEqual(model.balancedA.initialFraction, 0)
        XCTAssertEqual(model.balancedA.finalFraction, 1)

        XCTAssertEqual(model.balancedB.coords, Array(grid[3..<5] + grid[12..<15] + grid[25..<30]))
        XCTAssertEqual(model.balancedB.initialFraction, 0)
        XCTAssertEqual(model.balancedB.finalFraction, 1)

        XCTAssertEqual(model.balancedC.coords, model.initialReducingC.initialCoords)
        XCTAssertEqual(model.balancedC.initialFraction, 1)
        XCTAssertEqual(model.balancedC.finalFraction, 0.5)

        XCTAssertEqual(model.balancedD.coords, model.initialReducingD.initialCoords)
        XCTAssertEqual(model.balancedD.initialFraction, 1)
        XCTAssertEqual(model.balancedD.finalFraction, 0.5)
    }
}
