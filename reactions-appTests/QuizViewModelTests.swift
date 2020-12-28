//
// Reactions App
//

import XCTest
@testable import reactions_app

class QuizViewModelTests: XCTestCase {
    func testNavigatingBackAndThenForwardFromUnansweredQuestion() {
        let model = QuizViewModel(questions: QuizQuestion.zeroOrderQuestions)
        XCTAssertEqual(QuizState.pending, model.quizState)
        model.next()

        XCTAssertEqual(QuizState.running, model.quizState)
        XCTAssertTrue(model.selectedAnswer == nil)
        model.answer(option: QuizOption.A)
        XCTAssertTrue(model.selectedAnswer == QuizOption.A)
        XCTAssertTrue(model.questionIndex == 0)

        model.next()
        XCTAssertTrue(model.selectedAnswer == nil)
        XCTAssertTrue(model.questionIndex == 1)

        model.back()
        XCTAssertTrue(model.questionIndex == 0)
        XCTAssertTrue(model.selectedAnswer == QuizOption.A)

        model.next()
        XCTAssertTrue(model.questionIndex == 1)
        XCTAssertTrue(model.selectedAnswer == nil)
    }
}
