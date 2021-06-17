//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class ArcGeometryTests: XCTestCase {

    // Test case from https://sites.math.washington.edu/~conroy/m120-general/circleTangents.pdf
    func testTangentsForCircleAtOrigin() {
        let tangents = ArcGeometry.tangentOfCircleAtOrigin(withRadius: 2, through: CGPoint(x: 5, y: 3))
        XCTAssertNotNil(tangents)

        let asList = [tangents!.0, tangents!.1].sorted { $0.x < $1.x }

        XCTAssertEqual(asList[0].x, -0.37833, accuracy: 0.001)
        XCTAssertEqual(asList[0].y, 1.9639, accuracy: 0.001)

        XCTAssertEqual(asList[1].x, 1.5548, accuracy: 0.001)
        XCTAssertEqual(asList[1].y, -1.258, accuracy: 0.001)
    }

    func testTangentsForCircleNotAtOrigin() {
        let tangents = ArcGeometry.tangentOfCircle(
            withRadius: 2,
            center: CGPoint(x: 5, y: 10),
            through: CGPoint(x: 10, y: 13)
        )
        XCTAssertNotNil(tangents)

        let asList = [tangents!.0, tangents!.1].sorted { $0.x < $1.x }

        XCTAssertEqual(asList[0].x, 4.62117, accuracy: 0.001)
        XCTAssertEqual(asList[0].y, 11.9639, accuracy: 0.001)

        XCTAssertEqual(asList[1].x, 6.5548, accuracy: 0.001)
        XCTAssertEqual(asList[1].y, 8.742, accuracy: 0.001)
    }
}
