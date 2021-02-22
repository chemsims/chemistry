//
// Reactions App
//

import XCTest
@testable import reactions_app

class LastOpenedScreenTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testSettingAndGettingScreen() throws {
        let model = UserDefaultsLastOpenedScreenPersistence()
        XCTAssertNil(model.get())

        model.set(.reactionComparison)
        XCTAssertEqual(model.get(), .reactionComparison)
    }

}
