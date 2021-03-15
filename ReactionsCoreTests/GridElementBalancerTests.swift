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
            initialIncreasingA: GridElementToBalance(
                initialCoords: Array(grid[0..<10]),
                finalCount: 20
            ),
            initialIncreasingB: GridElementToBalance(
                initialCoords: Array(grid[10..<20]),
                finalCount: 20
            ),
            initialReducingC: GridElementToBalance(
                initialCoords: Array(grid[20..<40]),
                finalCount: 10
            ),
            initialReducingD: GridElementToBalance(
                initialCoords: Array(grid[40..<60]),
                finalCount: 10
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
            initialIncreasingA: GridElementToBalance(
                initialCoords: Array(grid[10..<20]),
                finalCount: 30
            ),
            initialIncreasingB: GridElementToBalance(
                initialCoords: Array(grid[20..<30]),
                finalCount: 30
            ),
            initialReducingC: GridElementToBalance(
                initialCoords: Array(grid[30..<50]),
                finalCount: 10
            ),
            initialReducingD: GridElementToBalance(
                initialCoords: Array(grid[50..<70]),
                finalCount: 10
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

    func testThisFailingCase() {
        let grid = GridCoordinate.grid(cols: 1, rows: 100)
        let initA = Array(grid[7..<22])
        let initB = Array(grid[37..<52])
        let initC = Array(grid[0..<4] + grid[30..<33] + grid[77..<100])
        let initD = Array(grid[4..<7] + grid[33..<37] + grid[54..<77])

        let model = GridElementBalancer(
            initialIncreasingA: GridElementToBalance(initialCoords: initA, finalCount: 27),
            initialIncreasingB: GridElementToBalance(initialCoords: initB, finalCount: 27),
            initialReducingC: GridElementToBalance(initialCoords: initC, finalCount: 24),
            initialReducingD: GridElementToBalance(initialCoords: initD, finalCount: 24),
            grid: grid
        )!

        print("\(initA.count)")
        print("\(initB.count)")

        XCTAssertEqual(model.balancedA.coords.count, 27)
        XCTAssertEqual(model.balancedB.coords.count, 27)

        XCTAssertEqual(model.balancedC.coords.count, 30)
        XCTAssertEqual(model.balancedD.coords.count, 30)
        XCTAssertEqual(model.balancedC.finalFraction, 1)
        XCTAssertEqual(model.balancedD.finalFraction, 1)
    }
}
