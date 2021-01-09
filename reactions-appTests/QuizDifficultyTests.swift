//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class QuizDifficultyTests: XCTestCase {

    func testGettingListOfQuestionsWithExactlyTheRightAmountOfOptions() {
        let easy = makeQuestions(5, .easy)
        let med = makeQuestions(5, .medium)
        let hard = makeQuestions(10, .hard)
        let questions = easy + med + hard

        XCTAssertEqual(availableQuestions(.easy, questions), easy)
        XCTAssertEqual(availableQuestions(.medium, questions), easy + med)
        XCTAssertEqual(availableQuestions(.hard, questions), easy + med + hard)
    }

    func testGettingListOfQuestionsWithADeficitOfEasyQuestions() {
        let easy = makeQuestions(4, .easy)
        let med = makeQuestions(11, .medium)
        let hard = makeQuestions(5, .hard)
        let questions = easy + med + hard

        XCTAssertEqual(availableQuestions(.easy, questions), easy + med.prefix(1))
        XCTAssertEqual(availableQuestions(.medium, questions), easy + med.prefix(6))
        XCTAssertEqual(availableQuestions(.hard, questions), questions)
    }

    func testGettingListOfQuestionsWithASurplusOfEasyQuestions() {
        let easy = makeQuestions(15, .easy)
        let med = makeQuestions(2, .medium)
        let hard = makeQuestions(3, .hard)
        let questions = easy + med + hard

        XCTAssertEqual(availableQuestions(.easy, questions), Array(easy.prefix(5)))
        XCTAssertEqual(availableQuestions(.medium, questions), Array(easy.prefix(10)))
        XCTAssertEqual(availableQuestions(.hard, questions), questions)
    }

    func testGettingListOfQuestionsWhenThereAreNotEnoughQuestions() {
        let easy = makeQuestions(4, .easy)
        let med = makeQuestions(4, .medium)
        let hard = makeQuestions(4, .hard)
        let questions = easy + med + hard

        XCTAssertEqual(availableQuestions(.easy, questions), easy + med.prefix(1))
        XCTAssertEqual(
            availableQuestions(.medium, questions),
            (easy + med) + Array(hard.prefix(2))
        )
        XCTAssertEqual(availableQuestions(.hard, questions), questions)
    }

    func testGettingListOfQuestionsWhenTheyAreNotOrderedByDifficulty() {
        let questions = [
            makeQuestion(.easy),
            makeQuestion(.medium),
            makeQuestion(.medium),
            makeQuestion(.hard),
            makeQuestion(.hard),
            makeQuestion(.hard),
            makeQuestion(.easy),
            makeQuestion(.hard),
            makeQuestion(.medium),
            makeQuestion(.easy),
            makeQuestion(.easy),
            makeQuestion(.medium),
            makeQuestion(.easy),
            makeQuestion(.medium),
        ]

        let expectedEasy = questions.filter { $0.difficulty == .easy }
        XCTAssertEqual(availableQuestions(.easy, questions), expectedEasy)

        let expectedMedium = questions.filter { $0.difficulty != .hard }
        XCTAssertEqual(availableQuestions(.medium, questions), expectedMedium)
    }

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
            options: [QuizOption:QuizAnswer](),
            correctOption: .A,
            explanation: nil,
            difficulty: difficulty,
            image: nil,
            table: nil
        )
    }

    private func availableQuestions(
        _ difficulty: QuizDifficulty,
        _ questions: [QuizQuestionDisplay]
    ) -> [QuizQuestionDisplay] {
        QuizDifficulty.availableQuestions(at: difficulty, questions: questions)
    }
}
