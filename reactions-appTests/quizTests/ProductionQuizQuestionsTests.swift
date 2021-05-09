//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import reactions_app

// Runs tests on the production quiz questions to catch easy mistakes
class ProductionQuizQuestionsTests: XCTestCase {

    func testUniqueIds() {
        testUniqueQuestionIds(questions: allQuestions)
    }

    func testOptionsAreNotTheSame() {
        testUniqueQuestionOptions(questions: allQuestions)
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
