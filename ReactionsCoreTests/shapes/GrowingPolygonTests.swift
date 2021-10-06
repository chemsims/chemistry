//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class GrowingPolygonTests: XCTestCase {

    func testGrowingADiamond() {
        let model = GrowingPolygon(
            directedPoints: [
                .init(point: CGPoint(x: 0.5, y: 0.5), angle: .zero), // right
                .init(point: CGPoint(x: 0.5, y: 0.5), angle: .degrees(90)), // bottom
                .init(point: CGPoint(x: 0.5, y: 0.5), angle: .degrees(180)), // left
                .init(point: CGPoint(x: 0.5, y: 0.5), angle: .degrees(270)) // top
            ]
        )

        let grown = model.grow(exactly: 0.5).points

        // right
        XCTAssertEqualWithTolerance(grown[0].x, 1)
        XCTAssertEqualWithTolerance(grown[0].y, 0.5)

        // bottom
        XCTAssertEqualWithTolerance(grown[1].x, 0.5)
        XCTAssertEqualWithTolerance(grown[1].y, 1)

        // left
        XCTAssertEqualWithTolerance(grown[2].x, 0)
        XCTAssertEqualWithTolerance(grown[2].y, 0.5)

        // top
        XCTAssertEqualWithTolerance(grown[3].x, 0.5)
        XCTAssertEqualWithTolerance(grown[3].y, 0)
    }

    func testGrowingPolygonDoesNotExceedLimits() {
        let model = GrowingPolygon(
            directedPoints: [
                .init(point: CGPoint(x: 0.5, y: 0.5), angle: .degrees(45)), // bottom right
                .init(point: CGPoint(x: 0.5, y: 0.5), angle: .degrees(135)), // bottom left
                .init(point: CGPoint(x: 0.5, y: 0.5), angle: .degrees(225)), // top left
                .init(point: CGPoint(x: 0.5, y: 0.5), angle: .degrees(315)) // top right
            ]
        )
        let grown = model.grow(exactly: 10).points

        XCTAssertEqual(grown[0], .init(x: 1, y: 1)) // bottom right
        XCTAssertEqual(grown[1], .init(x: 0, y: 1)) // bottom left
        XCTAssertEqual(grown[2], .init(x: 0, y: 0)) // top left
        XCTAssertEqual(grown[3], .init(x: 1, y: 0)) // top right
    }

}
