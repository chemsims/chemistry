//
// Reactions App
//

import XCTest
import ReactionsCore

class SpiralBeakerGridTests: XCTestCase {

    func testASingleElementInSymmetricOddGrid() {
        let coords = getList(cols: 3, rows: 3, count: 1)
        XCTAssertEqual(coords, [.init(col: 1, row: 1)])
    }

    func testASingleElementInSymmetricEvenGrid() {
        let coords = getList(cols: 4, rows: 4, count: 1)
        XCTAssertEqual(coords, [.init(col: 2, row: 2)])
    }

    func testASingleElementInAsymmetricGrid() {
        let coords = getList(cols: 7, rows: 4, count: 1)
        XCTAssertEqual(coords, [.init(col: 3, row: 2)])
    }

    func testAllElementsInSmallGrid() {
        let coords = getList(cols: 2, rows: 2, count: 4)
        XCTAssertEqual(
            coords, [
                .init(col: 1, row: 1),
                .init(col: 0, row: 1),
                .init(col: 0, row: 0),
                .init(col: 1, row: 0)
            ]
        )
    }

    func testElementsInSymmetricOddGrid() {
        let coords = getList(cols: 5, rows: 5, count: 9)
        XCTAssertEqual(
            coords, [
                .init(col: 2, row: 2),
                .init(col: 1, row: 2),
                .init(col: 1, row: 1),
                .init(col: 2, row: 1),
                .init(col: 3, row: 1),
                .init(col: 3, row: 2),
                .init(col: 3, row: 3),
                .init(col: 2, row: 3),
                .init(col: 1, row: 3),
            ])
    }

    func testElementsInAsymmetricGridWhichIsTooShortToFitSquare() {
        let coords = getList(cols: 5, rows: 2, count: 7)
        XCTAssertEqual(
            coords, [
                .init(col: 2, row: 1),
                .init(col: 1, row: 1),
                .init(col: 1, row: 0),
                .init(col: 2, row: 0),
                .init(col: 3, row: 0),
                .init(col: 3, row: 1),
                .init(col: 0, row: 1),
        ])
    }

    func testElementsInAsymmetricGridWhichIsTooNarrowToFitSquare() {
        let coords = getList(cols: 2, rows: 5, count: 7)
        XCTAssertEqual(
            coords, [
                .init(col: 1, row: 2),
                .init(col: 0, row: 2),
                .init(col: 0, row: 1),
                .init(col: 1, row: 1),
                .init(col: 1, row: 3),
                .init(col: 0, row: 3),
                .init(col: 0, row: 0),
            ])
    }

    func testElementsWhichDontAllFitInGrid() {
        let coords = getList(cols: 2, rows: 2, count: 10)
        XCTAssertEqual(
            coords, [
                .init(col: 1, row: 1),
                .init(col: 0, row: 1),
                .init(col: 0, row: 0),
                .init(col: 1, row: 0),
            ])
    }

    private func getList(cols: Int, rows: Int, count: Int) -> [GridCoordinate] {
        GridCoordinateList.spiralGrid(cols: cols, rows: rows, count: count)
    }
}
