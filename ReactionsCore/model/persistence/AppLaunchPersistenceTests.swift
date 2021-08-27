//
// Reactions App
//

import XCTest
import ReactionsCore

class AppLaunchPersistenceTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testRecordingNewAppLaunchSetsTheFirstDateExactlyOnce() {
        let model = UserDefaultsAppLaunchPersistence()

        XCTAssertNil(model.dateOfFirstAppLaunch)

        model.recordAppLaunch()
        let firstDate = model.dateOfFirstAppLaunch
        XCTAssertNotNil(firstDate)

        model.recordAppLaunch()

        let secondDate = model.dateOfFirstAppLaunch
        XCTAssertEqual(firstDate, secondDate)
    }

    func testRecordingNewAppLaunchIncrementsTheCount() {
        let model = UserDefaultsAppLaunchPersistence()

        XCTAssertEqual(model.countOfAppLaunches, 0)

        model.recordAppLaunch()
        XCTAssertEqual(model.countOfAppLaunches, 1)

        model.recordAppLaunch()
        XCTAssertEqual(model.countOfAppLaunches, 2)
    }
}
