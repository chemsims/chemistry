//
// Reactions App
//
  

import XCTest
@testable import reactions_app


class QuizPersistenceTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }

    func testSavingAndGettingASingleOption() {
        let model = newModel()
        let questions = zeroOrderQuestions()
        XCTAssertNil(model.getAnswers(questions))

        let answers = [
            questions[0].id : QuizAnswerInput(firstAnswer: .A)
        ]
        model.saveAnswers(questions, answers)
        XCTAssertEqual(model.getAnswers(questions), answers)
    }

    func testGettingAnAnswerWithOneOptionWhenTheOptionOrderingChanges() {
        let model = newModel()

        func questionWithCorrectOption(_ option: QuizOption) -> QuizQuestion {
            questionWithOptions([option], correctOption: option)
        }

        let firstQuestion = questionWithCorrectOption(.A)
        let answer = [ "0" : QuizAnswerInput(firstAnswer: .A)]
        model.saveAnswers([firstQuestion], answer)

        let firstQuestionDifferentOrder = questionWithCorrectOption(.B)
        let expected = ["0": QuizAnswerInput(firstAnswer: .B)]
        XCTAssertEqual(model.getAnswers([firstQuestionDifferentOrder]), expected)
    }

    func testGettingAnAnswersWithMultipleOptionsAndQuestions() {
        let model = newModel()
        let questions = zeroOrderQuestions()

        let answers = [
            questions[0].id : QuizAnswerInput(firstAnswer: .A, otherAnswers: [.B, .C, .D]),
            questions[1].id : QuizAnswerInput(firstAnswer: .B, otherAnswers: [.A, .C, .D]),
            questions[2].id : QuizAnswerInput(firstAnswer: .C, otherAnswers: [.B, .D, .A])
        ]

        model.saveAnswers(questions, answers)

        XCTAssertEqual(model.getAnswers(questions), answers)
    }

    func testGettingAnAnswerWithMultipleOptionsWhenTheOptionOrderingChanges() {
        let model = newModel()
        let q1 = questionWithOptions([.A, .B, .C, .D], correctOption: .A)
        let answers = [
            "0" : QuizAnswerInput(firstAnswer: .B, otherAnswers: [.A, .C, .D])
        ]

        model.saveAnswers([q1], answers)

        XCTAssertEqual(model.getAnswers([q1]), answers)

        let shuffledQ1 = questionWithOptions([.D, .C, .B, .A], correctOption: .D)
        let expected = [
            "0": QuizAnswerInput(firstAnswer: .C, otherAnswers: [.D, .B, .A])
        ]
        XCTAssertEqual(model.getAnswers([shuffledQ1]), expected)
    }

    private func zeroOrderQuestions() -> [QuizQuestion] {
        QuizQuestionsList.zeroOrderQuestions.createQuestions()
    }

    private func newModel() -> QuizPersistence {
        UserDefaultsQuizPersistence()
    }

    private func questionWithOptions(
        _ options: [QuizOption],
        correctOption: QuizOption
    ) -> QuizQuestion {

        var mappedOptions = [QuizOption:QuizAnswer]()
        options.enumerated().forEach { (i, option) in
            let answer = QuizAnswer(answer: "", explanation: "", id: i)
            mappedOptions[option] = answer
        }

        return QuizQuestion(
            id: "0",
            question: "",
            options: mappedOptions,
            correctOption: correctOption,
            difficulty: .easy,
            image: nil,
            table: nil
        )
    }
}

fileprivate extension QuizPersistence {
    func getAnswers(_ questions: [QuizQuestion]) -> [String: QuizAnswerInput]? {
        getAnswers(
            questionSet: .zeroOrder,
            questions: questions
        )?.answers
    }

    func saveAnswers(_ questions: [QuizQuestion], _ answers:[String: QuizAnswerInput]) {
        saveAnswers(
            quiz: SavedQuiz(
                questionSet: .zeroOrder,
                difficulty: .easy,
                answers: answers
            ),
            questions: questions
        )
    }
}
