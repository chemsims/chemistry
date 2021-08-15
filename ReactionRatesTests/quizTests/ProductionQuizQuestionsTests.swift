//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ReactionRates

// Runs tests on the production quiz questions to catch easy mistakes
class ProductionQuizQuestionsTests: XCTestCase {

    func testUniqueIds() {
        testUniqueQuestionIds(questions: allQuestions)
    }

    func testOptionsAreNotTheSame() {
        testUniqueQuestionOptions(questions: allQuestions)
    }

    func testTheProductionInjectorIsNotPersistingInMemory() {
        let model = ProductionReactionRatesInjector().quizPersistence
        let questions = QuizQuestionsList<ReactionsRateQuestionSet>.zeroOrderQuestions.createQuestions()

        var answers = [String:QuizAnswerInput]()
        questions.forEach { question in
            answers[question.id] = QuizAnswerInput(firstAnswer: .A)
        }

        let savedQuiz = SavedQuiz(
            questionSet: ReactionsRateQuestionSet.zeroOrder,
            difficulty: .hard,
            answers: answers
        )
        model.saveAnswers(quiz: savedQuiz, questions: questions)

        let model2 = ProductionReactionRatesInjector().quizPersistence
        XCTAssert(model !== model2)

        let retrievedQuiz = model2.getAnswers(questionSet: ReactionsRateQuestionSet.zeroOrder, questions: questions)
        XCTAssertNotNil(retrievedQuiz)
        XCTAssertEqual(retrievedQuiz!.answers, answers)
    }

    private var allQuestions: [QuizQuestion] {
        questions.flatMap { $0.createQuestions() }
    }

    private let questions = [
        QuizQuestionsList<ReactionsRateQuestionSet>.zeroOrderQuestions,
        QuizQuestionsList<ReactionsRateQuestionSet>.firstOrderQuestions,
        QuizQuestionsList<ReactionsRateQuestionSet>.secondOrderQuestions,
        QuizQuestionsList<ReactionsRateQuestionSet>.reactionComparisonQuizQuestions,
        QuizQuestionsList<ReactionsRateQuestionSet>.energyProfileQuizQuestions
    ]
}
