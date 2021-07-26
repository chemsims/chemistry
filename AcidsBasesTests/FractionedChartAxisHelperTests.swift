//
// Reactions App
//

import XCTest
@testable import AcidsBases

class FractionedChartAxisHelperTests: XCTestCase {
    func testPositiveChangeInPhWithZeroTargetDeltaPh() {
        let model = FractionedChartAxisHelper(
            initialPh: 1,
            middlePh: 5,
            minDelta: 0
        )

        XCTAssertEqual(model.minValue, 1)
        XCTAssertEqual(model.maxValue, 9)
    }

    func testPositiveChangeInPhWithNegativeTargetDeltaPh() {
        let model = FractionedChartAxisHelper(
            initialPh: 2,
            middlePh: 5,
            minDelta: -5
        )

        XCTAssertEqual(model.minValue, 0)
        XCTAssertEqual(model.maxValue, 10)
    }

    func testPositiveChangeInPhWithPositiveTargetDeltaPh() {
        let model = FractionedChartAxisHelper(
            initialPh: 2,
            middlePh: 5,
            minDelta: 6
        )

        XCTAssertEqual(model.minValue, -1)
        XCTAssertEqual(model.maxValue, 11)
    }

    func testNegativeChangeInPhWithZeroTargetDeltaPh() {
        let model = FractionedChartAxisHelper(
            initialPh: 7,
            middlePh: 5,
            minDelta: 0
        )

        XCTAssertEqual(model.minValue, 3)
        XCTAssertEqual(model.maxValue, 7)
    }

    func testNegativeChangeInPhNegativeTargetDeltaPh() {
        let model = FractionedChartAxisHelper(
            initialPh: 7,
            middlePh: 5,
            minDelta: -3
        )

        XCTAssertEqual(model.minValue, 2)
        XCTAssertEqual(model.maxValue, 8)
    }
}
