//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class FeedbackSettingsTests: XCTestCase {
    func testMailToUrlIsValid() {
        XCTAssertNotNil(FeedbackSettings().mailToUrl)
    }
}
