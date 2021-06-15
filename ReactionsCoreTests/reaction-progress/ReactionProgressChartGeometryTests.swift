//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class ReactionProgressChartGeometryTests: XCTestCase {

    func testGeometry() {
        let model = ReactionProgressChartGeometry(
            chartSize: 500,
            colCount: 4,
            maxMolecules: 10,
            topPadding: 100
        )

        XCTAssertEqual(model.moleculeSize, 40)
        XCTAssertEqual(model.position(colIndex: 0, rowIndex: 0), CGPoint(x: 100, y: 480))
        XCTAssertEqual(model.position(colIndex: 1, rowIndex: 0), CGPoint(x: 200, y: 480))
        XCTAssertEqual(model.position(colIndex: 2, rowIndex: 0), CGPoint(x: 300, y: 480))
        XCTAssertEqual(model.position(colIndex: 3, rowIndex: 0), CGPoint(x: 400, y: 480))

        XCTAssertEqual(model.position(colIndex: 0, rowIndex: 1), CGPoint(x: 100, y: 440))
        XCTAssertEqual(model.position(colIndex: 1, rowIndex: 1), CGPoint(x: 200, y: 440))
        XCTAssertEqual(model.position(colIndex: 2, rowIndex: 1), CGPoint(x: 300, y: 440))
        XCTAssertEqual(model.position(colIndex: 3, rowIndex: 1), CGPoint(x: 400, y: 440))

        XCTAssertEqual(model.position(colIndex: 0, rowIndex: 9), CGPoint(x: 100, y: 120))
        XCTAssertEqual(model.position(colIndex: 1, rowIndex: 9), CGPoint(x: 200, y: 120))
        XCTAssertEqual(model.position(colIndex: 2, rowIndex: 9), CGPoint(x: 300, y: 120))
        XCTAssertEqual(model.position(colIndex: 3, rowIndex: 9), CGPoint(x: 400, y: 120))
    }
}
