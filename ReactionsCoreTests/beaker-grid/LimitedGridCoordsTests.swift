//
// Reactions App
//

import XCTest
import ReactionsCore

class LimitedGridCoordsTests: XCTestCase {

    func testAddingCoords() {
        var model = LimitedGridCoords(
            grid: .init(rows: 10, cols: 10),
            initialCoords: [],
            otherCoords: [],
            minToAdd: 10,
            maxToAdd: 30
        )

        XCTAssert(model.canAdd)
        XCTAssertFalse(model.hasAddedEnough)

        model.add(count: 10)
        XCTAssert(model.canAdd)
        XCTAssert(model.hasAddedEnough)

        model.add(count: 50)
        XCTAssertEqual(model.coords.count, 30)
        XCTAssertFalse(model.canAdd)
        XCTAssert(model.hasAddedEnough)
    }

}
