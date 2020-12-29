//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class QuizDifficultyCountTests: XCTestCase {

    func testAllDifficultiesHaveOneQuestion() {
        let questions = makeQuestions(1, .easy) + makeQuestions(1, .medium) + makeQuestions(1, .hard)
        let count = QuizDifficulty.counts(questions: questions.shuffled())
        XCTAssertEqual(count[.easy], 1)
        XCTAssertEqual(count[.medium], 2)
        XCTAssertEqual(count[.hard], 3)
    }

    func testFirstTwoDifficultiesHaveQuestions() {
        let questions = makeQuestions(1, .easy) + makeQuestions(2, .medium)
        let count = QuizDifficulty.counts(questions: questions.shuffled())
        XCTAssertEqual(count[.easy], 1)
        XCTAssertEqual(count[.medium], 3)
        XCTAssertEqual(count[.hard], 0)
    }

    func testFirstAndLastDifficultiesHaveQuestions() {
        let questions = makeQuestions(2, .easy) + makeQuestions(2, .hard)
        let count = QuizDifficulty.counts(questions: questions)
        XCTAssertEqual(count[.easy], 2)
        XCTAssertEqual(count[.medium], 0)
        XCTAssertEqual(count[.hard], 4)
    }

    func testFirstDifficultyHasNoQuestion() {
        let questions = makeQuestions(2, .medium) + makeQuestions(1, .hard)
        let count = QuizDifficulty.counts(questions: questions)
        XCTAssertEqual(count[.easy], 0)
        XCTAssertEqual(count[.medium], 2)
        XCTAssertEqual(count[.hard], 3)
    }

    private func makeQuestions(_ count: Int, _ difficulty: QuizDifficulty) -> [QuizQuestionDisplay] {
        (1...count).map { _ in
            makeQuestion(difficulty)
        }
    }

    private func makeQuestion(_ difficulty: QuizDifficulty) -> QuizQuestionDisplay {
        QuizQuestionDisplay(
            question: "",
            options: [QuizOption:TextLine](),
            correctOption: .A,
            explanation: nil,
            difficulty: difficulty,
            image: nil,
            table: nil
        )
    }
}
