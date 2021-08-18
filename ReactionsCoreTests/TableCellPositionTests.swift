//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class TableCellPositionTests: XCTestCase {

    func testSingleRowAndCol() {
        let position = TableCellPosition.position(
            in: CGRect(
                x: 20,
                y: 30,
                width: 40,
                height: 50
            ),
            rows: 1,
            cols: 1,
            rowIndex: 0,
            colIndex: 0
        )


        XCTAssertEqual(position, CGPoint(x: 40, y: 55))
    }

    func testSecondColAndThirdOfFourthRow() {
        let position = TableCellPosition.position(
            in: CGRect(
                x: 20,
                y: 30,
                width: 40,
                height: 80
            ),
            rows: 4,
            cols: 2,
            rowIndex: 2,
            colIndex: 1
        )

        XCTAssertEqual(position, CGPoint(x: 50, y: 80))
    }
}
