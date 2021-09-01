//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import AcidsBases

class AcidBasesQuizQuestionTests: XCTestCase {

    func testUniqueIds() {
        testUniqueQuestionIds(questions: allQuestions)
    }

    func testUniqueOptions() {
        testUniqueQuestionOptions(questions: allQuestions)
    }

    private var allQuestions: [QuizQuestion] {
        questions.flatMap { $0.createQuestions() }
    }

    private let questions = [
        QuizQuestionsList<AcidBasesQuestionSet>.introduction,
        QuizQuestionsList<AcidBasesQuestionSet>.buffer,
        QuizQuestionsList<AcidBasesQuestionSet>.titration
    ]
}
