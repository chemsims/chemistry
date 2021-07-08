//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class ReactionProgressChartGeometryTests: XCTestCase {

    func testGeometry() {
        let model = ReactionProgressChartGeometry(
            chartSize: 500,
            moleculeType: TestEnum.self,
            maxMolecules: 10,
            topPadding: 100
        )

        let barWidth = 500 / 4.0
        let firstColX = barWidth / 2
        let expectedColX = [firstColX, firstColX + barWidth, firstColX + (2 * barWidth), firstColX + (3 * barWidth)]

        // Available height is 400 for 10 molecules, so expected molecule size is 40
        XCTAssertEqual(model.moleculeSize, 40)

        XCTAssertEqual(model.position(colIndex: 0, rowIndex: 0), CGPoint(x: expectedColX[0], y: 480))
        XCTAssertEqual(model.position(colIndex: 1, rowIndex: 0), CGPoint(x: expectedColX[1], y: 480))
        XCTAssertEqual(model.position(colIndex: 2, rowIndex: 0), CGPoint(x: expectedColX[2], y: 480))
        XCTAssertEqual(model.position(colIndex: 3, rowIndex: 0), CGPoint(x: expectedColX[3], y: 480))

        XCTAssertEqual(model.position(colIndex: 0, rowIndex: 1), CGPoint(x: expectedColX[0], y: 440))
        XCTAssertEqual(model.position(colIndex: 1, rowIndex: 1), CGPoint(x: expectedColX[1], y: 440))
        XCTAssertEqual(model.position(colIndex: 2, rowIndex: 1), CGPoint(x: expectedColX[2], y: 440))
        XCTAssertEqual(model.position(colIndex: 3, rowIndex: 1), CGPoint(x: expectedColX[3], y: 440))

        XCTAssertEqual(model.position(colIndex: 0, rowIndex: 9), CGPoint(x: expectedColX[0], y: 120))
        XCTAssertEqual(model.position(colIndex: 1, rowIndex: 9), CGPoint(x: expectedColX[1], y: 120))
        XCTAssertEqual(model.position(colIndex: 2, rowIndex: 9), CGPoint(x: expectedColX[2], y: 120))
        XCTAssertEqual(model.position(colIndex: 3, rowIndex: 9), CGPoint(x: expectedColX[3], y: 120))
    }

    private enum TestEnum: CaseIterable {
        case A, B, C, D
    }
}
