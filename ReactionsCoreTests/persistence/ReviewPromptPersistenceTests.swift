//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class ReviewPromptPersistenceTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testSavingReviewVersion() {
        let model = newModel()
        XCTAssertNil(model.getLastPromptInfo())

        let info = PromptInfo.firstPrompt()
        model.setPromptInfo(info)
        XCTAssertEqual(model.getLastPromptInfo()?.count, info.count)
        XCTAssertEqual(model.getLastPromptInfo()?.date, info.date)
    }

    private func newModel() -> ReviewPromptPersistence {
        UserDefaultsReviewPromptPersistence()
    }

}
