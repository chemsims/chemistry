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

        func getAnswers() -> [String:QuizAnswerInput]? {
            persistence.getAnswers(
                questionSet: .zeroOrder,
                questions: questionList.createQuestions()
            )?.answers
        }

        XCTAssertEqual(model.quizState, .pending)
        XCTAssertNil(getAnswers())

        model.quizDifficulty = .medium
        model.next()

        XCTAssertEqual(model.quizState, .running)

        model.answer(option: .B)
        model.answer(option: .C)
        model.answer(option: .D)

        let answer1 = [
            "0": QuizAnswerInput(firstAnswer: .B, otherAnswers: [.C, .D])
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
            "0": QuizAnswerInput(firstAnswer: .A)
        ]
        XCTAssertEqual(getAnswers(), answer2)
    }

    func testThatTheQuizStateIsRestoredIfTheQuizWasCompleted() {
        let persistence = InMemoryQuizPersistence()
        let questions = makeQuestions(n: 3)
        let model = newModel(questions, persistence: persistence)

        model.next()
        model.answer(option: .A)
        model.next()
        model.answer(option: .B)
        model.next()
        model.answer(option: .C)
        model.next()

        XCTAssertEqual(model.quizState, .completed)

        let model2 = newModel(questions, persistence: persistence)
        XCTAssertEqual(model2.quizState, .completed)
        XCTAssertEqual(model.currentQuestion.id, "2")
        let expectedAnswers = [
            "0": QuizAnswerInput(firstAnswer: .A),
            "1": QuizAnswerInput(firstAnswer: .B),
            "2": QuizAnswerInput(firstAnswer: .C)
        ]
        XCTAssertEqual(model.answers, expectedAnswers)
    }

    func testThatExplanationsAreShownWhenForIncorrectSelectedAnswers() {
        let questions = makeQuestions(n: 3)
        let model = newModel(questions)

        func notShown(_ options: [QuizOption]) {
            options.forEach { o in
                XCTAssertFalse(model.showExplanation(option: o))
            }
        }

        func shown(_ options: [QuizOption]) {
            options.forEach { o in
                XCTAssertTrue(model.showExplanation(option: o))
            }
        }

        model.next()
        notShown([.B, .C, .D])

        model.answer(option: .D)
        shown([.D])
        notShown([.B, .C])

        model.next()
        notShown(QuizOption.allCases)
        model.back()
        shown([.D])
        notShown([.B, .C])

        model.next()
        model.answer(option: .A)
        notShown(QuizOption.allCases)
    }

    private func makeQuestions(n: Int) -> QuizQuestionsList {
        QuizQuestionsList(questionSet: .zeroOrder, (0..<n).map(makeQuestion))
    }

    private func makeQuestion(i: Int) -> QuizQuestionData {

        func answer(_ suffix: String, _ position: QuizOption) -> QuizAnswerData {
            QuizAnswerData(
                answer: "\(i) - \(suffix)",
                explanation: "\(i)",
                position: position
            )
        }

        return QuizQuestionData(
            id: "\(i)",
            question: "\(i)",
            correctAnswer: answer("A", .A),
            otherAnswers: [
                answer("B", .B),
                answer("C", .C),
                answer("D", .D)
            ],
            difficulty: .easy
        )
    }

    func newModel(
        _ questions: QuizQuestionsList,
        persistence: QuizPersistence = InMemoryQuizPersistence()
    ) -> QuizViewModel {
        QuizViewModel(questions: questions, persistence: persistence, analytics: NoOpAnalytics())
    }

}
