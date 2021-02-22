//
// Reactions App
//

import XCTest
@testable import reactions_app

class QuizQuestionTests: XCTestCase {

    func testCorrectOption() {
        let quizData = QuizQuestionData(id: "1", question: "foo", correctAnswer: newAnswer("answer"), otherAnswers: [], difficulty: .easy)
        let quiz = quizData.createQuestion()
        XCTAssertEqual(quiz.options.count, 1)
        XCTAssertEqual(quiz.question, quizData.question)
        XCTAssertEqual(quiz.options[quiz.correctOption], quizData.correctAnswer.toAnswer(i: -1))
    }

    func testCorrectOptionWithPosition() {
        let quizData = QuizQuestionData(
            id: "1",
            question: "foo",
            correctAnswer: newAnswer("answer", position: .D),
            otherAnswers: [],
            difficulty: .easy
        )
        let quiz = quizData.createQuestion()
        XCTAssertEqual(quiz.options.count, 1)
        XCTAssertEqual(quiz.options.keys.first, .D)
        XCTAssertEqual(quiz.correctOption, .D)
        XCTAssertEqual(quiz.options[.D], quizData.correctAnswer.toAnswer(i: -1))
    }

    func testCorrectionOptionNoPositionAndSingleOtherOptionWithPosition() {
        let quizData = QuizQuestionData(
            id: "1",
            question: "foo",
            correctAnswer: newAnswer("answer"),
            otherAnswers: [
                newAnswer("wrong answer", position: .D)
            ],
            difficulty: .easy
        )
        let quiz = quizData.createQuestion()
        XCTAssertEqual(quiz.options.count, 2)
        XCTAssertEqual(quiz.options[.D], quizData.otherAnswers.first!.toAnswer(i: 0))
        XCTAssertNotEqual(quiz.correctOption, .D)
        XCTAssertEqual(quiz.options[quiz.correctOption], quizData.correctAnswer.toAnswer(i: -1))
    }

    func testCorrectionOptionWithPositionAndOtherOptionsWithMixedPositions() {
        let quizData = QuizQuestionData(
            id: "1",
            question: "foo",
            correctAnswer: newAnswer("answer", position: .D),
            otherAnswers: [
                newAnswer("wrong 1", position: .A),
                newAnswer("wrong 2", position: .C),
                newAnswer("wrong 3", position: nil)
            ],
            difficulty: .easy
        )
        let quiz = quizData.createQuestion()
        let expected = [
            QuizOption.A: quizData.otherAnswers[0].toAnswer(i: 0),
            QuizOption.B: quizData.otherAnswers[2].toAnswer(i: 2),
            QuizOption.C: quizData.otherAnswers[1].toAnswer(i: 1),
            QuizOption.D: quizData.correctAnswer.toAnswer(i: -1)
        ]
        XCTAssertEqual(quiz.correctOption, .D)
        XCTAssertEqual(quiz.options, expected)
    }

    func testOtherOptionsWhereOnlyTheLastHasAPosition() {
        let quizData = QuizQuestionData(
            id: "1",
            question: "foo",
            correctAnswer: newAnswer("answer"),
            otherAnswers: [
                newAnswer("wrong 1"),
                newAnswer("wrong 2"),
                newAnswer("wrong 3", position: .A)
            ],
            difficulty: .easy
        )
        let quiz = quizData.createQuestion()
        XCTAssertEqual(quiz.options[.A], quizData.otherAnswers.last!.toAnswer(i: 2))
    }

    private func newAnswer(_ str: String, position: QuizOption? = nil) -> QuizAnswerData {
        QuizAnswerData(
            answer: str,
            explanation: str,
            position: position
        )
    }

    /// Since the quiz options are generated randomly, all tests are run multiple times to avoid flaky tests
    override func invokeTest() {
        (0...4).forEach { _ in
            super.invokeTest()
        }
    }

}

fileprivate extension QuizAnswerData {
    func toAnswer(i: Int) -> QuizAnswer {
        QuizAnswer(
            answer: answer,
            explanation: explanation,
            id: i == -1 ? "CORRECT-ANSWER" : "INCORRECT-ANSWER-\(i + 1)"
        )
    }
}
