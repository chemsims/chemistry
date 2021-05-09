//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class SizeAdjusterTests: XCTestCase {

    func testIncreasingSmallElement() {
        let adjusted1 = SizeAdjuster.adjust(
            sizes: [1, 100],
            minElementSize: 5,
            maximumSum: 105
        )
        let adjusted2 = SizeAdjuster.adjust(
            sizes: [100, 1],
            minElementSize: 5,
            maximumSum: 105
        )
        XCTAssertEqual(adjusted1, [5, 100])
        XCTAssertEqual(adjusted2, [100, 5])
    }

    func testRemainingWithinBoundsWithTwoLargeElementsOfTheSameSize() {
        let adjusted = SizeAdjuster.adjust(
            sizes: [100, 100],
            minElementSize: 1,
            maximumSum: 100
        )
        XCTAssertEqual(adjusted, [50, 50])
    }

    func testRemainingWithinBoundsWithTwoLargeElementsOfDifferentSize() {
        let adjusted = SizeAdjuster.adjust(
            sizes: [50, 200],
            minElementSize: 0,
            maximumSum: 50
        )
        XCTAssertEqual(adjusted, [10, 40])
    }

    func testRemainingWithinBoundsWithASmallElementAndALargeElement() {
        let adjusted = SizeAdjuster.adjust(
            sizes: [5, 100],
            minElementSize: 5,
            maximumSum: 50
        )
        assertArrayEquals(adjusted, [5, 45])
    }

    func testIncreasingMinSizeAndRemainingWithinBoundsForMultipleElements() {
        let adjusted = SizeAdjuster.adjust(
            sizes: [1, 10, 60, 100, 400, 1000],
            minElementSize: 50,
            maximumSum: 400
        )
        let expectedPenultimate = (200.0 / 1400.0) * 400.0
        let expectedFinal = 400 - 200 - expectedPenultimate
        assertArrayEquals(adjusted, [50, 50, 50, 50, expectedPenultimate, expectedFinal])
    }

    private func assertArrayEquals<T: BinaryFloatingPoint>(_ lhs: [T], _ rhs: [T], _ accuracy: T = 0.0001) {
        XCTAssertEqual(lhs.count, rhs.count)
        (0..<lhs.count).forEach { i in
            XCTAssertEqual(lhs[i], rhs[i], accuracy: accuracy)
        }
    }

}
