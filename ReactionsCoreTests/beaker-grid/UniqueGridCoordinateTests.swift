//
// Reactions App
//

import XCTest
import ReactionsCore

class UniqueGridCoordinateTests: XCTestCase {

    func testAnEmptyList() {
        XCTAssertEqual(getUnique([[]]), [[]])
    }

    func testASingleListWithNoDuplicates() {
        let elements = [[coord(0), coord(1), coord(2)]]
        XCTAssertEqual(getUnique(elements), elements)
    }

    func testASingleListWithDuplicates() {
        let elements = [[coord(0), coord(1), coord(0)]]
        let expected = [[coord(0), coord(1)]]
        XCTAssertEqual(getUnique(elements), expected)
    }

    func testMultipleListsWithDuplicates() {
        let elements = [
            [coord(0), coord(1), coord(2), coord(3), coord(0)],
            [coord(3), coord(4), coord(5)],
            [coord(0), coord(1), coord(2)]
        ]
        let expected = [
            [coord(0), coord(1), coord(2), coord(3)],
            [coord(4), coord(5)],
            []
        ]
        XCTAssertEqual(getUnique(elements), expected)
    }

    private func coord(_ value: Int) -> GridCoordinate {
        GridCoordinate(col: value, row: value)
    }

    private func getUnique(_ coords: [[GridCoordinate]]) -> [[GridCoordinate]] {
        GridCoordinate.uniqueGridCoordinates(coords: coords)
    }

}
