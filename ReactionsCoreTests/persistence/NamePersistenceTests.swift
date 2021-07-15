//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class NamePersistenceTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testSettingNonNilName() {
        let model = UserDefaultsNamePersistence()
        XCTAssertNil(model.name)

        model.name = "Lisa"
        XCTAssertEqual(model.name, "Lisa")
    }

    func testSettingNilName() {
        let model = UserDefaultsNamePersistence()
        model.name = "Lisa"
        XCTAssertNotNil(model.name)

        model.name = nil
        XCTAssertNil(model.name)
    }
}
