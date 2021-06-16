//
// Reactions App
//

import XCTest
import ReactionsCore

class TextLineUtilTests: XCTestCase {

    func testParsingScientificNumbers() {
        doTest(1e-5, "1.0x10^-5^")
        doTest(0.1, "1.0x10^-1^")
        doTest(1, "1.0x10^0^")
        doTest(10, "1.0x10^1^")
        doTest(123.456, "1.2x10^2^")
        doTest(0.000000012345, "1.2x10^-8^")
        doTest(12340000.567, "1.2x10^7^")
    }

    private func doTest(_ l: CGFloat, _ r: String) {
        XCTAssertEqual(TextLineUtil.scientific(value: l), TextLine(r))
    }
}
