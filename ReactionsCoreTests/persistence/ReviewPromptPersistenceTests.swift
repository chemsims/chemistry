//
// Reactions App
//

import XCTest
import ReactionsCore

class ReviewPromptPersistenceTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testSavingReviewVersion() {
        let model = newModel()
        XCTAssertNil(model.lastPromptedVersion())
        model.setPromptedVersion(version: "version-1")
        XCTAssertEqual(model.lastPromptedVersion(), "version-1")
        model.setPromptedVersion(version: "version-2")
        XCTAssertEqual(model.lastPromptedVersion(), "version-2")
    }

    private func newModel() -> ReviewPromptPersistence {
        UserDefaultsReviewPromptPersistence()
    }

}
