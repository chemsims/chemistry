//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import reactions_equilibrium

class PumpViewModelTests: XCTestCase {

    func testMovingOneDivisions() {
        var count = 0
        let model = PumpViewModel(
            initialExtensionFactor: 1,
            divisions: 1,
            onDownPump: { count += 1}
        )

        XCTAssertEqual(count, 0)

        model.moved(to: 0.1)
        XCTAssertEqual(count, 0)

        model.moved(to: 0)
        XCTAssertEqual(count, 1)

        model.moved(to: 1)
        XCTAssertEqual(count, 1)

        model.moved(to: 0)
        XCTAssertEqual(count, 2)
    }

    func testMovingTwoDivisions() {
        var count = 0
        let model = PumpViewModel(
            initialExtensionFactor: 1,
            divisions: 2,
            onDownPump: { count += 1}
        )

        model.moved(to: 0.51)
        XCTAssertEqual(count, 0)

        model.moved(to: 0.49)
        XCTAssertEqual(count, 1)

        model.moved(to: 0)
        XCTAssertEqual(count, 2)

        model.moved(to: 1)
        XCTAssertEqual(count, 2)

        model.moved(to: 0)
        XCTAssertEqual(count, 4)
    }

    func testMovingManyDivisions() {
        var count = 0
        let model = PumpViewModel(
            initialExtensionFactor: 1,
            divisions: 5,
            onDownPump: { count += 1}
        )

        model.moved(to: 0.81)
        XCTAssertEqual(count, 0)

        model.moved(to: 0.79)
        XCTAssertEqual(count, 1)

        model.moved(to: 0.61)
        XCTAssertEqual(count, 1)

        model.moved(to: 0.59)
        XCTAssertEqual(count, 2)

        model.moved(to: 0.41)
        XCTAssertEqual(count, 2)

        model.moved(to: 0.39)
        XCTAssertEqual(count, 3)

        model.moved(to: 0.21)
        XCTAssertEqual(count, 3)

        model.moved(to: 0.19)
        XCTAssertEqual(count, 4)

        model.moved(to: 0.1)
        XCTAssertEqual(count, 4)

        model.moved(to: 0)
        XCTAssertEqual(count, 5)

        model.moved(to: 1)
        XCTAssertEqual(count, 5)

        model.moved(to: 0)
        XCTAssertEqual(count, 10)
    }

}
