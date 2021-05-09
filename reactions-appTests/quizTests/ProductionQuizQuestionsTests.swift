//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import reactions_app

// Runs tests on the production quiz questions to catch easy mistakes
class ProductionQuizQuestionsTests: XCTestCase {

    func testUniqueIds() {
        // Rather then just compare size of set to size of questions, check each element so that any duplicate is printed immediately
        let allIds = allQuestions.map(\.id)
        allIds.forEach { id in
            XCTAssertEqual(allIds.filter { $0 == id }.count, 1, id)
        }
    }

    func testOptionsAreNotTheSame() {
        allQuestions.forEach { question in
            let allAnswers = question.options.values
            allAnswers.forEach { answer in
                let filteredAnswer = allAnswers.filter { $0.answer == answer.answer }
                let filteredExplanation = allAnswers.filter { $0.explanation == answer.explanation }

                let debug = "\(question.id) - \(answer)"

                XCTAssertEqual(filteredAnswer.count, 1, debug)
                XCTAssertEqual(filteredExplanation.count, 1, debug)
            }
        }
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
