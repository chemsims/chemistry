//
// Reactions App
//

import XCTest
@testable import reactions_app

class QuizViewModelTests: XCTestCase {

    func testNavigatingBackAndThenForwardFromUnansweredQuestion() {
        let model = newModel(.zeroOrderQuestions)
        XCTAssertEqual(QuizState.pending, model.quizState)
        model.next()

        XCTAssertEqual(QuizState.running, model.quizState)
        XCTAssertTrue(model.selectedAnswer == nil)
        model.answer(option: QuizOption.A)
        XCTAssertTrue(model.selectedAnswer == QuizAnswerInput(firstAnswer: .A))
        XCTAssertTrue(model.currentIndex == 0)

        model.next()
        XCTAssertTrue(model.selectedAnswer == nil)
        XCTAssertTrue(model.currentIndex == 1)

        model.back()
        XCTAssertTrue(model.currentIndex == 0)
        XCTAssertTrue(model.selectedAnswer == QuizAnswerInput(firstAnswer: .A))

        model.next()
        XCTAssertTrue(model.currentIndex == 1)
        XCTAssertTrue(model.selectedAnswer == nil)
    }

    func testTakingASmallQuiz() {
        let questions = makeQuestions(n: 5)
        let model = newModel(questions)

        XCTAssertEqual(model.quizState, .pending)

        // Question 1
        model.next()
        XCTAssertEqual(model.quizState, .running)
        XCTAssertEqual(model.question.plainString, "0")

        model.answer(option: .A)
        XCTAssertTrue(model.hasSelectedCorrectOption)

        // Question 2
        model.next()
        XCTAssertFalse(model.hasSelectedCorrectOption)

        model.answer(option: .B)
        XCTAssertFalse(model.hasSelectedCorrectOption)
        XCTAssertNotNil(model.selectedAnswer)
        XCTAssertEqual(model.selectedAnswer!.firstAnswer, .B)

        model.answer(option: .C)
        XCTAssertFalse(model.hasSelectedCorrectOption)
        XCTAssertEqual(model.selectedAnswer!.firstAnswer, .B)
        XCTAssertEqual(model.selectedAnswer!.allAnswers, [.B, .C])

        model.answer(option: .A)
        XCTAssertTrue(model.hasSelectedCorrectOption)

        // Question 3
        model.next()
        XCTAssertFalse(model.hasSelectedCorrectOption)
        model.answer(option: .A)
        XCTAssertTrue(model.hasSelectedCorrectOption)
        model.back()
        XCTAssertTrue(model.hasSelectedCorrectOption)
        model.next()
        XCTAssertTrue(model.hasSelectedCorrectOption)

        // Skip 4 & 5 End the quiz
        model.next()
        model.next()
        model.next()

        XCTAssertEqual(model.quizState, .completed)
        let qs = questions.createQuestions()
        let answer1 = model.selectedAnswer(id: qs.first!.id)

        XCTAssertEqual(answer1, QuizAnswerInput(firstAnswer: .A))

        let answer2 = model.selectedAnswer(id: qs[1].id)
        XCTAssertEqual(answer2, QuizAnswerInput(firstAnswer: .B, otherAnswers: [.C, .A]))

        let answer3 = model.selectedAnswer(id: qs[2].id)
        XCTAssertEqual(answer3, QuizAnswerInput(firstAnswer: .A))

        XCTAssertNil(model.selectedAnswer(id: qs[3].id))
        XCTAssertNil(model.selectedAnswer(id: qs[4].id))
    }

    func testThatTheQuizIsSavedWhenItEnds() {
        let persistence = InMemoryQuizPersistence()
        let questionList = QuizQuestionsList(questionSet: .zeroOrder, [makeQuestion(i: 0)])
        let model = newModel(questionList, persistence: persistence)

        func getAnswers() -> [Int:QuizAnswerInput] {
            persistence.getAnswers(
                difficulty: .medium,
                questionSet: .zeroOrder,
                questions: questionList.createQuestions()
            )
        }

        XCTAssertEqual(model.quizState, .pending)
        XCTAssertEqual(getAnswers(), [:])

        model.quizDifficulty = .medium
        model.next()

        XCTAssertEqual(model.quizState, .running)

        model.answer(option: .B)
        model.answer(option: .C)
        model.answer(option: .D)

        let answer1 = [
            0: QuizAnswerInput(firstAnswer: .B, otherAnswers: [.C, .D])
        ]
        model.next()

        XCTAssertEqual(model.quizState, .completed)
        XCTAssertEqual(getAnswers(), answer1)

        model.restart()
        XCTAssertEqual(getAnswers(), answer1)

        model.next()
        model.answer(option: .A)
        model.next()
        let answer2 = [
            0: QuizAnswerInput(firstAnswer: .A)
        ]
        XCTAssertEqual(getAnswers(), answer2)
    }

    private func makeQuestions(n: Int) -> QuizQuestionsList {
        QuizQuestionsList(questionSet: .zeroOrder, (0..<n).map(makeQuestion))
    }

    private func makeQuestion(i: Int) -> QuizQuestionData {
        QuizQuestionData(
            question: TextLine(stringLiteral: "\(i)"),
            correctAnswer: QuizAnswerData(answer: TextLine(stringLiteral: "\(i) - A"), position: .A),
            otherAnswers: [
                QuizAnswerData(answer: TextLine(stringLiteral: "\(i) - B"), position: .B),
                QuizAnswerData(answer: TextLine(stringLiteral: "\(i) - C"), position: .C),
                QuizAnswerData(answer: TextLine(stringLiteral: "\(i) - D"), position: .D)
            ],
            explanation: "",
            difficulty: .easy
        )
    }

    func newModel(
        _ questions: QuizQuestionsList,
        persistence: QuizPersistence = InMemoryQuizPersistence()
    ) -> QuizViewModel {
        QuizViewModel(questions: questions, persistence: persistence )
    }

}
