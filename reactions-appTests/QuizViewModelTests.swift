//
// Reactions App
//

import XCTest
@testable import reactions_app

class QuizViewModelTests: XCTestCase {

    func testNavigatingBackAndThenForwardFromUnansweredQuestion() {
        let model = QuizViewModel()
        model.hasSelectedAnswer = true
        model.next()
        model.back()
        model.next()
        XCTAssertEqual(model.hasSelectedAnswer, false)
    }

}
