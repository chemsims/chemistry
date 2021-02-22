//
// Reactions App
//

import XCTest
@testable import reactions_app

class CGFloatRoundingTests: XCTestCase {

    func testRounding() {
        XCTAssertEqual(CGFloat(123).rounded(decimals: 2), 123)
        XCTAssertEqual(CGFloat(123.456).rounded(decimals: 2), 123.46)
        XCTAssertEqual(CGFloat(123.456789).rounded(decimals: 2), 123.46)
        XCTAssertEqual(CGFloat(123.453).rounded(decimals: 2), 123.45)
        XCTAssertEqual(CGFloat(123.456).rounded(decimals: 2), 123.46)
        XCTAssertEqual(CGFloat(0.01234).rounded(decimals: 2), 0.01)
        XCTAssertEqual(CGFloat(0.00001).rounded(decimals: 2), 0)

        XCTAssertEqual(CGFloat(-123.45).rounded(decimals: 2), -123.45)
        XCTAssertEqual(CGFloat(-1.1).rounded(decimals: 2), -1.1)
        XCTAssertEqual(CGFloat(-1.12345).rounded(decimals: 2), -1.12)
        XCTAssertEqual(CGFloat(-0.091).rounded(decimals: 2), -0.09)
    }

}
