//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import reactions_equilibrium

class EquilibriumQuizQuestionTests: XCTestCase {

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
        QuizQuestionsList<EquilibriumQuestionSet>.aqueous,
        QuizQuestionsList<EquilibriumQuestionSet>.gaseous,
        QuizQuestionsList<EquilibriumQuestionSet>.solubility
    ]
}
