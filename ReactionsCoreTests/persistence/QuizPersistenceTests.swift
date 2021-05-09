//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class QuizPersistenceTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.clearAll()
    }

    func testSavingAndGettingASingleOption() {
        let model = newModel()
        let questions = zeroOrderQuestions()
        XCTAssertNil(model.getAnswers(questions))

        let answers = [
            questions[0].id: QuizAnswerInput(firstAnswer: .A)
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
        let answer = [ "0": QuizAnswerInput(firstAnswer: .A)]
        model.saveAnswers([firstQuestion], answer)

        let firstQuestionDifferentOrder = questionWithCorrectOption(.B)
        let expected = ["0": QuizAnswerInput(firstAnswer: .B)]
        XCTAssertEqual(model.getAnswers([firstQuestionDifferentOrder]), expected)
    }

    func testGettingAnAnswersWithMultipleOptionsAndQuestions() {
        let model = newModel()
        let questions = zeroOrderQuestions()

        let answers = [
            questions[0].id: QuizAnswerInput(firstAnswer: .A, otherAnswers: [.B, .C, .D]),
            questions[1].id: QuizAnswerInput(firstAnswer: .B, otherAnswers: [.A, .C, .D]),
            questions[2].id: QuizAnswerInput(firstAnswer: .C, otherAnswers: [.B, .D, .A])
        ]

        model.saveAnswers(questions, answers)

        XCTAssertEqual(model.getAnswers(questions), answers)
    }

    func testGettingAnAnswerWithMultipleOptionsWhenTheOptionOrderingChanges() {
        let model = newModel()
        let q1 = questionWithOptions([.A, .B, .C, .D], correctOption: .A)
        let answers = [
            "0": QuizAnswerInput(firstAnswer: .B, otherAnswers: [.A, .C, .D])
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
        QuizQuestionsList<Int>.testQuestions.createQuestions()
    }

    private func newModel() -> UserDefaultsQuizPersistence<Int> {
        UserDefaultsQuizPersistence<Int>()
    }

    private func questionWithOptions(
        _ options: [QuizOption],
        correctOption: QuizOption
    ) -> QuizQuestion {

        var mappedOptions = [QuizOption: QuizAnswer]()
        options.enumerated().forEach { (i, option) in
            let answer = QuizAnswer(answer: "", explanation: "", id: "\(i)")
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

extension Int: RawRepresentable {
    public var rawValue: String {
        "\(self)"
    }

    public typealias RawValue = String

    public init?(rawValue: String) {
        guard let i = Int(rawValue) else {
            return nil
        }
        self = i
    }


}

fileprivate extension QuizPersistence where QuestionSet == Int {
    func getAnswers(_ questions: [QuizQuestion]) -> [String: QuizAnswerInput]? {
        getAnswers(
            questionSet: 0,
            questions: questions
        )?.answers
    }

    func saveAnswers(_ questions: [QuizQuestion], _ answers: [String: QuizAnswerInput]) {
        saveAnswers(
            quiz: SavedQuiz(
                questionSet: 0,
                difficulty: .easy,
                answers: answers
            ),
            questions: questions
        )
    }
}


private extension QuizQuestionsList where QuestionSet == Int {
    static let testQuestions = QuizQuestionsList(
        questionSet: 0,
        [
            QuizQuestionData(
                id: "1",
                question: "1 + 1?",
                correctAnswer: QuizAnswerData(answer: "2", explanation: ""),
                otherAnswers: [
                    QuizAnswerData(answer: "1", explanation: ""),
                    QuizAnswerData(answer: "3", explanation: ""),
                    QuizAnswerData(answer: "4", explanation: ""),
                ],
                difficulty: .easy
            ),
            QuizQuestionData(
                id: "2",
                question: "2 + 2?",
                correctAnswer: QuizAnswerData(answer: "4", explanation: ""),
                otherAnswers: [
                    QuizAnswerData(answer: "1", explanation: ""),
                    QuizAnswerData(answer: "3", explanation: ""),
                    QuizAnswerData(answer: "0", explanation: ""),
                ],
                difficulty: .medium
            ),
            QuizQuestionData(
                id: "3",
                question: "3 + 3?",
                correctAnswer: QuizAnswerData(answer: "6", explanation: ""),
                otherAnswers: [
                    QuizAnswerData(answer: "1", explanation: ""),
                    QuizAnswerData(answer: "3", explanation: ""),
                    QuizAnswerData(answer: "4", explanation: ""),
                ],
                difficulty: .hard
            )
        ]
    )
}
