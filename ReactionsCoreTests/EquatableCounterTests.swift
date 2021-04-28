//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class EquatableCounterTests: XCTestCase {

    func testEquatableCounter() throws {
        var counter = EquatableCounter<TestEnum>()
        XCTAssertEqual(counter.count, 0)

        counter.increment(value: .A)
        XCTAssertEqual(counter.count, 1)

        counter.increment(value: .A)
        XCTAssertEqual(counter.count, 2)

        counter.increment(value: .B)
        XCTAssertEqual(counter.count, 1)

        counter.reset()
        XCTAssertEqual(counter.count, 0)
    }
}

private enum TestEnum: Equatable {
    case A, B
}
