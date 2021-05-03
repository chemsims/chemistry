//
// Reactions App
//

import XCTest

class AppURLCanBeOpenedTests: XCTestCase {

    func testThatTheAppCanBeFoundByURL() throws {
        let url = URL(string: "reactionrate://app")!
        XCTAssert(UIApplication.shared.canOpenURL(url))
    }
}
