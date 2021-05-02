//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class QuizQuestionReaderTests: XCTestCase {

    func testReadingExampleFile() {
        let file = "Quiz Parsing Test Case"
        let quizOpt = QuizQuestionReader.read(
            from: file,
            questionSet: .energyProfile,
            bundle: Bundle(for: type(of: self))
        )

        XCTAssertNotNil(quizOpt)

        guard let quiz = quizOpt else {
            return
        }
        XCTAssertEqual(quiz.questionSet, .energyProfile)

        let questions = quiz.questions

        // MARK: Test difficulties
        XCTAssertEqual(questions[0].difficulty, .easy)
        XCTAssertEqual(questions[1].difficulty, .medium)
        XCTAssertEqual(questions[2].difficulty, .hard)

        // MARK: Test answer text & explanations
        for i in questions.indices {
            let question = quiz.questions[i]
            XCTAssertEqual(question.id, "\(i)")

            func checkAnswer(_ data: QuizAnswerData, _ text: String) {
                XCTAssertEqual(data.answer, "\(text) \(i)")
                XCTAssertEqual(data.explanation, "explanation \(text) \(i)")
            }

            checkAnswer(question.correctAnswer, "correct answer")
            checkAnswer(question.otherAnswers[0], "wrong answer 1")
            checkAnswer(question.otherAnswers[1], "wrong answer 2")
            checkAnswer(question.otherAnswers[2], "wrong answer 3")
        }

        // MARK: Test positions
        func positions(_ index: Int) -> [QuizOption?] {
            [questions[index].correctAnswer.position] + questions[index].otherAnswers.map(\.position)
        }
        XCTAssertEqual(positions(0), [nil, nil, nil, .D])
        XCTAssertEqual(positions(1), [nil, nil, nil, nil])
        XCTAssertEqual(positions(2), [.D, .B, .A, .C])


        // MARK: Test image
        let expectedImage = LabelledImage(image: "q2-image", label: "q2 image label")
        XCTAssertEqual(questions[0].image, nil)
        XCTAssertEqual(questions[1].image, expectedImage)
        XCTAssertEqual(questions[2].image, nil)


        // MARK: Test table
        let expectedTable = QuizTable(
            rows: [
                ["A", "B", "C"],
                ["1", "2", "3"],
                ["4", "5", "6"]
            ]
        )
        XCTAssertEqual(questions[0].table, nil)
        XCTAssertEqual(questions[1].table, nil)
        XCTAssertEqual(questions[2].table, expectedTable)
    }
}
