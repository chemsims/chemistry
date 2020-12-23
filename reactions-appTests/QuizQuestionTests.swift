//
// Reactions App
//
  

import XCTest
@testable import reactions_app


class QuizQuestionTests: XCTestCase {

    func testCorrectOption() {
        let quizData = QuizQuestion(question: "foo", correctAnswer: "answer", otherAnswers: [], explanation: nil, difficulty: .easy)
        let quiz = quizData.randomDisplay()
        XCTAssertEqual(quiz.options.count, 1)
        XCTAssertEqual(quiz.question, quizData.question)
        XCTAssertEqual(quiz.options[quiz.correctOption], quizData.correctAnswer.answer)
    }

    func testCorrectOptionWithPosition() {
        let quizData = QuizQuestion(
            question: "foo",
            correctAnswer: QuizAnswer(answer: "answer", explanation: nil, position: .D),
            otherAnswers: [],
            explanation: nil,
            difficulty: .easy
        )
        let quiz = quizData.randomDisplay()
        XCTAssertEqual(quiz.options.count, 1)
        XCTAssertEqual(quiz.options.keys.first, .D)
        XCTAssertEqual(quiz.correctOption, .D)
        XCTAssertEqual(quiz.options[.D], quizData.correctAnswer.answer)
    }

    func testCorrectionOptionNoPositionAndSingleOtherOptionWithPosition() {
        let quizData = QuizQuestion(
            question: "foo",
            correctAnswer: "answer",
            otherAnswers: [
                QuizAnswer(answer: "wrong answer", explanation: nil, position: .D)
            ],
            explanation: nil,
            difficulty: .easy
        )
        let quiz = quizData.randomDisplay()
        XCTAssertEqual(quiz.options.count, 2)
        XCTAssertEqual(quiz.options[.D], quizData.otherAnswers.first!.answer)
        XCTAssertNotEqual(quiz.correctOption, .D)
        XCTAssertEqual(quiz.options[quiz.correctOption], quizData.correctAnswer.answer)
    }

    func testCorrectionOptionWithPositionAndOtherOptionsWithMixedPositions() {
        let quizData = QuizQuestion(
            question: "foo",
            correctAnswer: QuizAnswer(answer: "answer", explanation: nil, position: .D),
            otherAnswers: [
                QuizAnswer(answer: "wrong 1", explanation: nil, position: .A),
                QuizAnswer(answer: "wrong 2", explanation: nil, position: .C),
                QuizAnswer(answer: "wrong 3", explanation: nil, position: nil),
            ],
            explanation: nil,
            difficulty: .easy
        )
        let quiz = quizData.randomDisplay()
        let expected = [
            QuizOption.A: quizData.otherAnswers[0].answer,
            QuizOption.B: quizData.otherAnswers[2].answer,
            QuizOption.C: quizData.otherAnswers[1].answer,
            QuizOption.D: quizData.correctAnswer.answer
        ]
        XCTAssertEqual(quiz.correctOption, .D)
        XCTAssertEqual(quiz.options, expected)
    }

    func testOtherOptionsWhereOnlyTheLastHasAPosition() {
        let quizData = QuizQuestion(
            question: "foo",
            correctAnswer: "bar",
            otherAnswers: [
                "wrong 1",
                "wrong 2",
                QuizAnswer(answer: "wrong 3", explanation: nil, position: .A)
            ],
            explanation: nil,
            difficulty: .easy
        )
        let quiz = quizData.randomDisplay()
        XCTAssertEqual(quiz.options[.A], quizData.otherAnswers.last!.answer)
    }

    /// Since the function chooses random elements, all tests are run multiple times to avoid flaky tests
    override func invokeTest() {
        (0...4).forEach { _ in
            super.invokeTest()
        }
    }

}
