//
// Reactions App
//

import XCTest
@testable import reactions_app

class FeedbackSettingsTests: XCTestCase {
    func testMailToUrlIsValid() {
        XCTAssertNotNil(FeedbackSettings.mailToUrl)
    }
}
