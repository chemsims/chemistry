//
// Reactions App
//

import XCTest
import ReactionsCore

class StringUtilTests: XCTestCase {

    func testCombineStringsWithFinalAnd() {
        func combine(_ elements: [String]) -> String {
            StringUtil.combineStringsWithFinalAnd(elements)
        }

        XCTAssertEqual(combine([]), "")
        XCTAssertEqual(combine(["a"]), "a")
        XCTAssertEqual(combine(["a", "b"]), "a and b")
        XCTAssertEqual(combine(["a", "b", "c"]), "a, b and c")
        XCTAssertEqual(combine(["a", "b", "c", "d"]), "a, b, c and d")
    }

    func testCombineStringsWithComma() {
        func combine(_ elements: [String]) -> String {
            StringUtil.combineStrings(elements)
        }

        XCTAssertEqual(combine([]), "")
        XCTAssertEqual(combine(["a"]), "a")
        XCTAssertEqual(combine(["a", "b"]), "a, b")
        XCTAssertEqual(combine(["a", "b", "c"]), "a, b, c")
        XCTAssertEqual(combine(["a", "b", "c", "d"]), "a, b, c, d")
    }
}
