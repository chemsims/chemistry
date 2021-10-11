//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class GrowingPolygonTests: XCTestCase {

    func testGrowingADiamond() {
        let center = CGPoint(x: 0.5, y: 0.5)
        let model = GrowingPolygon3(
            center: center,
            points: 4,
            pointGrowth: 0.5,
            firstPointAngle: .zero
        )

        XCTAssertEqual(model.points.count, 4)

        model.points.forEach { point in
            XCTAssertEqual(point.getPoint(at: 0), center)
        }

        func checkMatchingPoint(_ expected: CGPoint) {
            let found = model.points.filter { point in
                pointsAreEqual(point.getPoint(at: 1), expected)
            }
            XCTAssertEqual(found.count, 1)
        }

        checkMatchingPoint(CGPoint(x: 0.5, y: 0)) // top
        checkMatchingPoint(CGPoint(x: 1, y: 0.5)) // right
        checkMatchingPoint(CGPoint(x: 0.5, y: 1)) // bottom
        checkMatchingPoint(CGPoint(x: 0, y: 0.5)) // left
    }

    func testGrowingPolygonDoesNotExceedLimits2() {
        let model = GrowingPolygon3(
            center: CGPoint(x: 0.5, y: 0.5),
            points: 4,
            pointGrowth: 10,
            firstPointAngle: .degrees(45)
        )

        func checkMatchingPoint(_ expected: CGPoint) {
            let found = model.points.filter { point in
                pointsAreEqual(point.getPoint(at: 1), expected)
            }
            XCTAssertEqual(found.count, 1)
        }

        checkMatchingPoint(CGPoint(x: 1, y: 1)) // bottom right
        checkMatchingPoint(CGPoint(x: 0, y: 1)) // bottom left
        checkMatchingPoint(CGPoint(x: 0, y: 0)) // top left
        checkMatchingPoint(CGPoint(x: 1, y: 0)) // top right
    }

    func testBoundingRect() {
        let model = GrowingPolygon3(
            center: CGPoint(x: 0.5, y: 0.5),
            points: 4,
            pointGrowth: 0.5,
            firstPointAngle: .zero
        )

        let initialRect = model.boundingRect(at: 0)
        XCTAssertEqual(initialRect.origin, CGPoint(x: 0.5, y: 0.5))
        XCTAssertEqual(initialRect.size, .zero)

        let finalRect = model.boundingRect(at: 1)
        XCTAssertEqual(finalRect.origin, CGPoint(x: 0, y: 0))
        XCTAssertEqual(finalRect.size, CGSize(width: 1, height: 1))
    }

    // Rounds the point values before comparing to account for
    // differences in floating point arithmetic
    private func pointsAreEqual(_ l: CGPoint, _ r: CGPoint) -> Bool {
        func areEqual(_ l: CGFloat, _ r: CGFloat) -> Bool {
            l.rounded(decimals: 5) == r.rounded(decimals: 5)
        }

        return areEqual(l.x, r.x) && areEqual(l.y, r.y)
    }


}
