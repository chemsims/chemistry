//
// Reactions App
//

import XCTest
@testable import APChemistry

class ValidURLTests: XCTestCase {
    func testVirkPaperURL() {
        XCTAssertNotNil(URL.virk2013PaperOptionalUrl)
    }
}
