//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class QuizQuestionReaderTests: XCTestCase {

    func testReadingExampleFile() {
        let file = "quiz-parse-valid-file"
        let quizResult = read(file)

        XCTAssertNotNil(quizResult.option, "Errors: \n\(String(describing: quizResult.error?.list()))")

        guard let quiz = quizResult.option else {
            return
        }

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

    func testMissingFile() {
        let file = "missing-file"
        XCTAssertEqual(read(file).error!.list(), [.missingFile])
    }

    func testInvalidDifficulty() {
        let errors = getErrors("quiz-parse-invalid-difficulty")
        XCTAssertEqual(errors, [.invalidDifficulty(rowIndex: 2, content: "invalid-difficulty")])
    }

    func testInvalidPosition() {
        let errors = getErrors("quiz-parse-invalid-position")
        let col = Columns.shared.correctPos
        XCTAssertEqual(errors, [.invalidPosition(rowIndex: 2, name: col.name, content: "G")])
    }

    func testInvalidImages() {
        let errors = getErrors("quiz-parse-invalid-images")
        let expected = [
            missingCell(row: 2, \.imageLabel),
            missingCell(row: 3, \.image)
        ]
        XCTAssertEqual(errors, expected)
    }

    func testInvalidTables() {
        let errors = getErrors("quiz-parse-invalid-tables")
        let expected: [QuizReadFailure] = [
            .invalidTable(rowIndex: 2),
            .invalidTable(rowIndex: 3)
        ]
        XCTAssertEqual(errors, expected)
    }

    func testMissingFields() {
        let errors = getErrors("quiz-parse-missing-fields")

        func cell(_ kp: KeyPath<Columns, Column>) -> QuizReadFailure {
            missingCell(row: 2, kp)
        }

        let expected: [QuizReadFailure] = [
            cell(\.question), cell(\.difficulty), cell(\.correctText), cell(\.correctExplanation),
            cell(\.incorrect1Text), cell(\.incorrect1Explanation), cell(\.incorrect2Text), cell(\.incorrect2Explanation),
            cell(\.incorrect3Text), cell(\.incorrect3Explanation)
        ]
        XCTAssertEqual(errors, expected)
    }

    func missingCell(row: Int, _ kp: KeyPath<Columns, Column>) -> QuizReadFailure {
        .missingCell(rowIndex: row, name: Columns.shared[keyPath: kp].name)
    }

    private func getErrors(_ file: String) -> [QuizReadFailure] {
        read(file).error?.list() ?? []
    }

    private func read(_ file: String) -> ReadResult<QuizQuestionsList> {
        QuizQuestionReader.read(
            from: file,
            questionSet: .zeroOrder,
            bundle: Bundle(for: type(of: self))
        )
    }
}

extension Columns {
    var correctExplanation: Column {
        Self.explanationCol(question: correctText)
    }
    var correctPos: Column {
        Self.positionCol(question: correctText)
    }

    var incorrect1Explanation: Column {
        Self.explanationCol(question: incorrect1Text)
    }

    var incorrect2Explanation: Column {
        Self.explanationCol(question: incorrect2Text)
    }

    var incorrect3Explanation: Column {
        Self.explanationCol(question: incorrect3Text)
    }
}
