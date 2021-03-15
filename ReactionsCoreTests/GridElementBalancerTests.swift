//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class GridElementBalancerTests: XCTestCase {

    func testReducingElementsAreTransferredToIncreasingElementsProportionally() throws {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let model = GridElementBalancer(
            increasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: [],
                    finalCount: 10
                ),
                second: GridElementToBalance(
                    initialCoords: [],
                    finalCount: 10
                )
            ),
            decreasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: Array(grid[0..<20]),
                    finalCount: 10
                ),
                second: GridElementToBalance(
                    initialCoords: Array(grid[20..<40]),
                    finalCount: 10
                )
            ),
            grid: grid
        )!

        XCTAssertEqual(model.balancedA.coords, Array(grid[0..<5] + grid[20..<25]))
        XCTAssertEqual(model.balancedA.initialFraction, 0)
        XCTAssertEqual(model.balancedA.finalFraction, 1)

        XCTAssertEqual(model.balancedB.coords, Array(grid[5..<10] + grid[25..<30]))
        XCTAssertEqual(model.balancedB.initialFraction, 0)
        XCTAssertEqual(model.balancedB.finalFraction, 1)

        XCTAssertEqual(model.balancedC.coords, model.initialReducingC.initialCoords)
        XCTAssertEqual(model.balancedC.initialFraction, 1)
        XCTAssertEqual(model.balancedC.finalFraction, 1)

        XCTAssertEqual(model.balancedD.coords, model.initialReducingD.initialCoords)
        XCTAssertEqual(model.balancedD.initialFraction, 1)
        XCTAssertEqual(model.balancedD.finalFraction, 1)
    }

    func testReducingElementsAreTransferredToIncreasedElementsWithDifferentProportions() {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let model = GridElementBalancer(
            increasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: [],
                    finalCount: 10
                ),
                second: GridElementToBalance(
                    initialCoords: [],
                    finalCount: 10
                )
            ),
            decreasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: Array(grid[0..<30]),
                    finalCount: 15
                ),
                second: GridElementToBalance(
                    initialCoords: Array(grid[30..<60]),
                    finalCount: 25
                )
            ),
            grid: grid
        )!

        XCTAssertEqual(model.balancedA.coords, Array(grid[0..<8] + grid[30..<32]))
        XCTAssertEqual(model.balancedA.initialFraction, 0)
        XCTAssertEqual(model.balancedA.finalFraction, 1)

        XCTAssertEqual(model.balancedB.coords, Array(grid[8..<15] + grid[32..<35]))
        XCTAssertEqual(model.balancedB.initialFraction, 0)
        XCTAssertEqual(model.balancedB.finalFraction, 1)

        XCTAssertEqual(model.balancedC.coords, model.initialReducingC.initialCoords)
        XCTAssertEqual(model.balancedC.initialFraction, 1)
        XCTAssertEqual(model.balancedC.finalFraction, 1)

        XCTAssertEqual(model.balancedD.coords, model.initialReducingD.initialCoords)
        XCTAssertEqual(model.balancedD.initialFraction, 1)
        XCTAssertEqual(model.balancedD.finalFraction, 1)
    }

    func testOverallReductionInNumberOfElements() {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let model = GridElementBalancer(
            increasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: [],
                    finalCount: 10
                ),
                second: GridElementToBalance(
                    initialCoords: [],
                    finalCount: 10
                )
            ),
            decreasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: Array(grid[0..<30]),
                    finalCount: 15
                ),
                second: GridElementToBalance(
                    initialCoords: Array(grid[30..<60]),
                    finalCount: 15
                )
            ),
            grid: grid
        )!

        XCTAssertEqual(model.balancedA.coords, Array(grid[0..<5] + grid[30..<35]))
        XCTAssertEqual(model.balancedA.initialFraction, 0)
        XCTAssertEqual(model.balancedA.finalFraction, 1)

        XCTAssertEqual(model.balancedB.coords, Array(grid[5..<10] + grid[35..<40]))
        XCTAssertEqual(model.balancedB.initialFraction, 0)
        XCTAssertEqual(model.balancedB.finalFraction, 1)

        XCTAssertEqual(model.balancedC.coords, model.initialReducingC.initialCoords)
        XCTAssertEqual(model.balancedC.initialFraction, 1)
        XCTAssertEqual(model.balancedC.finalFraction, 0.833, accuracy: 0.001)

        XCTAssertEqual(model.balancedD.coords, model.initialReducingD.initialCoords)
        XCTAssertEqual(model.balancedD.initialFraction, 1)
        XCTAssertEqual(model.balancedD.finalFraction, 0.833, accuracy: 0.001)
    }

    func testOverallIncreaseInElements() {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let model = GridElementBalancer(
            increasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: [],
                    finalCount: 10
                ),
                second: GridElementToBalance(
                    initialCoords: [],
                    finalCount: 10
                )
            ),
            decreasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: Array(grid[0..<10]),
                    finalCount: 5
                ),
                second: GridElementToBalance(
                    initialCoords: Array(grid[10..<20]),
                    finalCount: 5
                )
            ),
            grid: grid
        )!

        XCTAssertEqual(model.balancedA.coords, Array(grid[0..<3] + grid[10..<12] + grid[20..<25]))
        XCTAssertEqual(model.balancedA.initialFraction, 0)
        XCTAssertEqual(model.balancedA.finalFraction, 1)

        XCTAssertEqual(model.balancedB.coords, Array(grid[3..<5] + grid[12..<15] + grid[25..<30]))
        XCTAssertEqual(model.balancedB.initialFraction, 0)
        XCTAssertEqual(model.balancedB.finalFraction, 1)

        XCTAssertEqual(model.balancedC.coords, model.initialReducingC.initialCoords)
        XCTAssertEqual(model.balancedC.initialFraction, 1)
        XCTAssertEqual(model.balancedC.finalFraction, 1)

        XCTAssertEqual(model.balancedD.coords, model.initialReducingD.initialCoords)
        XCTAssertEqual(model.balancedD.initialFraction, 1)
        XCTAssertEqual(model.balancedD.finalFraction, 1)
    }

    func testIncreasesElementsWhereStartingCoordsAreNonEmpty() {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let model = GridElementBalancer(
            increasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: Array(grid[0..<10]),
                    finalCount: 20
                ),
                second: GridElementToBalance(
                    initialCoords: Array(grid[10..<20]),
                    finalCount: 20
                )
            ),
            decreasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: Array(grid[20..<40]),
                    finalCount: 10
                ),
                second: GridElementToBalance(
                    initialCoords: Array(grid[40..<60]),
                    finalCount: 10
                )
            ),
            grid: grid
        )!

        XCTAssertEqual(model.balancedA.coords, Array(grid[0..<10] + grid[20..<25] + grid[40..<45]))
        XCTAssertEqual(model.balancedA.initialFraction, 0.5)
        XCTAssertEqual(model.balancedA.finalFraction, 1)

        XCTAssertEqual(model.balancedB.coords, Array(grid[10..<20] + grid[25..<30] + grid[45..<50]))
        XCTAssertEqual(model.balancedB.initialFraction, 0.5)
        XCTAssertEqual(model.balancedB.finalFraction, 1)
    }

    func testIncreasingElementsWhereThereAreAlsoInitialElementsOfAAndB() {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let model = GridElementBalancer(
            increasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: Array(grid[10..<20]),
                    finalCount: 30
                ),
                second: GridElementToBalance(
                    initialCoords: Array(grid[20..<30]),
                    finalCount: 30
                )
            ),
            decreasingElements: GridElementPair(
                first: GridElementToBalance(
                    initialCoords: Array(grid[30..<50]),
                    finalCount: 10
                ),
                second: GridElementToBalance(
                    initialCoords: Array(grid[50..<70]),
                    finalCount: 10
                )
            ),
            grid: grid
        )!

        let aFromCD = Array(grid[30..<35] + grid[50..<55])
        let extraA = Array(grid[0..<10])
        let expectedA = Array(grid[10..<20]) + aFromCD + extraA
        XCTAssertEqual(model.balancedA.coords, expectedA)
        XCTAssertEqual(model.balancedA.initialFraction, 0.333, accuracy: 0.001)
        XCTAssertEqual(model.balancedA.finalFraction, 1)

        let bFromCD = Array(grid[35..<40] + grid[55..<60])
        let extraB = Array(grid[70..<80])
        let expectedB = Array(grid[20..<30]) + bFromCD + extraB
        XCTAssertEqual(model.balancedB.coords, expectedB)
        XCTAssertEqual(model.balancedB.initialFraction, 0.333, accuracy: 0.001)
        XCTAssertEqual(model.balancedB.finalFraction, 1)

        XCTAssertEqual(model.balancedC.coords, model.initialReducingC.initialCoords)
        XCTAssertEqual(model.balancedC.initialFraction, 1)
        XCTAssertEqual(model.balancedC.finalFraction, 1)

        XCTAssertEqual(model.balancedD.coords, model.initialReducingD.initialCoords)
        XCTAssertEqual(model.balancedD.initialFraction, 1)
        XCTAssertEqual(model.balancedD.finalFraction, 1)
    }
}

private extension GridElementBalancer {
    var balancedA: BalancedGridElement {
        increasingBalanced.first
    }

    var balancedB: BalancedGridElement {
        increasingBalanced.second
    }

    var balancedC: BalancedGridElement {
        decreasingBalanced.first
    }

    var balancedD: BalancedGridElement {
        decreasingBalanced.second
    }

}
