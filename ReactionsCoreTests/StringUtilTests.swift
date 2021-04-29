//
// Reactions App
//

import XCTest
import ReactionsCore

class StringUtilTests: XCTestCase {

    func testEmptyElements() {
        XCTAssertEqual(combine([]), "")
    }

    func testOneElement() {
        XCTAssertEqual(combine(["a"]), "a")
    }

    func testTwoElements() {
        XCTAssertEqual(combine(["a", "b"]), "a and b")
    }

    func testThreeElements() {
        XCTAssertEqual(combine(["a", "b", "c"]), "a, b and c")
    }

    func testFourElements() {
        XCTAssertEqual(combine(["a", "b", "c", "d"]), "a, b, c and d")
    }

    private func combine(_ elements: [String]) -> String {
        StringUtil.combineStringsWithFinalAnd(elements)
    }

}
