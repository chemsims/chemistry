//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class QuizViewModelTests: XCTestCase {

    func testNavigatingBackAndThenForwardFromUnansweredQuestion() {
        let model = newModel(makeQuestions(n: 5))
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

        // Question 4 & 5 then the end the quiz
        XCTAssertNil(model.selectedAnswer(id: questions.createQuestions()[3].id))
        XCTAssertNil(model.selectedAnswer(id: questions.createQuestions()[4].id))
        model.next()
        model.answer(option: .A)
        model.next()
        model.answer(option: .A)
        model.next()

        XCTAssertEqual(model.quizState, .completed)
        let qs = questions.createQuestions()
        let answer1 = model.selectedAnswer(id: qs.first!.id)

        XCTAssertEqual(answer1, QuizAnswerInput(firstAnswer: .A))

        let answer2 = model.selectedAnswer(id: qs[1].id)
        XCTAssertEqual(answer2, QuizAnswerInput(firstAnswer: .B, otherAnswers: [.C, .A]))

        let answer3 = model.selectedAnswer(id: qs[2].id)
        XCTAssertEqual(answer3, QuizAnswerInput(firstAnswer: .A))

        XCTAssertEqual(model.selectedAnswer(id: qs[3].id), QuizAnswerInput(firstAnswer: .A))
        XCTAssertEqual(model.selectedAnswer(id: qs[4].id), QuizAnswerInput(firstAnswer: .A))
    }

    func testThatTheQuizIsSavedWhenItEnds() {
        let persistence = InMemoryQuizPersistence<Int>()
        let questionList = QuizQuestionsList(questionSet: 0, [makeQuestion(id: 0)])
        let model = newModel(questionList, persistence: persistence)

        func getAnswers() -> [String: QuizAnswerInput]? {
            persistence.getAnswers(
                questionSet: 0,
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
        model.next(force: true)

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
        let persistence = InMemoryQuizPersistence<Int>()
        let questions = makeQuestions(n: 3)
        let model = newModel(questions, persistence: persistence)

        model.next()
        model.answer(option: .A)
        model.next()
        model.answer(option: .B)
        model.next(force: true)
        model.answer(option: .C)
        model.next(force: true)

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

        model.next(force: true)
        notShown(QuizOption.allCases)
        model.back()
        shown([.D])
        notShown([.B, .C])

        model.next(force: true)
        model.answer(option: .A)
        notShown(QuizOption.allCases)
    }

    func testCurrentQuestionIsValidWhenFirstQuestionIsNotAnEasyOne() {
        let medium = makeQuestions(n: 5, difficulty: .medium)
        let easy = makeQuestions(n: 5, difficulty: .easy, idOffset: 5)

        let questions = QuizQuestionsList(questionSet: 0, medium.questions + easy.questions)

        let model = newModel(questions)

        model.quizDifficulty = .easy
        model.next()
        XCTAssertEqual(model.currentQuestion.id, "5")
    }

    private func makeQuestions(n: Int, difficulty: QuizDifficulty = .easy, idOffset: Int = 0) -> QuizQuestionsList<Int> {
        QuizQuestionsList(questionSet: 0, (0..<n).map { makeQuestion(id: $0 + idOffset, difficulty: difficulty) } )
    }

    private func makeQuestion(id: Int, difficulty: QuizDifficulty = .easy) -> QuizQuestionData {

        func answer(_ suffix: String, _ position: QuizOption) -> QuizAnswerData {
            QuizAnswerData(
                answer: "\(id) - \(suffix)",
                explanation: "\(id)",
                position: position
            )
        }

        return QuizQuestionData(
            id: "\(id)",
            question: "\(id)",
            correctAnswer: answer("A", .A),
            otherAnswers: [
                answer("B", .B),
                answer("C", .C),
                answer("D", .D)
            ],
            difficulty: difficulty
        )
    }

    func newModel(
        _ questions: QuizQuestionsList<Int>,
        persistence: InMemoryQuizPersistence<Int> = InMemoryQuizPersistence<Int>()
    ) -> QuizViewModel<InMemoryQuizPersistence<Int>, NoOpAppAnalytics<Int, Int>> {
        QuizViewModel(
            questions: questions,
            persistence: persistence,
            analytics: NoOpAppAnalytics<Int, Int>(),
            bundle: nil
        )
    }

}
