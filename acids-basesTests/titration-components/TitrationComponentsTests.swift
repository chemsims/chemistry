//
// Reactions App
//

import XCTest
@testable import acids_bases

class TitrationComponentsTests: XCTestCase {

    func testCoordsWhenIncrementingStrongAcid() {
        let model = newModel()
        XCTAssert(model.substanceCoords.coords.isEmpty)
        model.incrementStrongAcid(count: 1)
        XCTAssertEqual(model.substanceCoords.coords.count, 1)
    }

    private func newModel() -> TitrationComponents {
        TitrationComponents(cols: 10, rows: 10)
    }
}
