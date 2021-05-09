//
// Reactions App
//

import XCTest
import ReactionsCore

class LastOpenedScreenTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testSettingAndGettingScreen() throws {
        let model = UserDefaultsScreenPersistence<TestEnum>()
        XCTAssertNil(model.lastOpened())

        model.setLastOpened(.A)
        XCTAssertEqual(model.lastOpened(), .A)
    }

}

private enum TestEnum: String {
    case A
}
