//
// Reactions App
//

import XCTest
import ReactionsCore

class TextLineUtilTests: XCTestCase {

    func testParsingScientificNumbers() {
        doTest(1e-5, "1x10^-5^")
        doTest(0.1, "1x10^-1^")
        doTest(1, "1x10^0^")
        doTest(10, "1x10^1^")
        doTest(123.456, "1.2x10^2^")
    }

    private func doTest(_ l: CGFloat, _ r: String) {
        XCTAssertEqual(TextLineUtil.scientific(value: l), TextLine(r))
    }
}
