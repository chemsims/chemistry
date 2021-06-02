//
// Reactions App
//

import Foundation
import ReactionsCore

extension QuizQuestionsList where QuestionSet == EquilibriumQuestionSet {
    static let aqueous = EquilibriumQuizQuestions.aqueous!
    static let gaseous = EquilibriumQuizQuestions.gaseous!
    static let solubility = EquilibriumQuizQuestions.solubility!
}

struct EquilibriumQuizQuestions {
    private init() { }

    static func load() {
        aqueous = read("aqueous-quiz", .aqueous)
        gaseous = read("gaseous-quiz", .gaseous)
        solubility = read("solubility-quiz", .solubility)
    }

    private(set) fileprivate static var aqueous: QuizQuestionsList<EquilibriumQuestionSet>!
    private(set) fileprivate static var gaseous: QuizQuestionsList<EquilibriumQuestionSet>!
    private(set) fileprivate static var solubility: QuizQuestionsList<EquilibriumQuestionSet>!

    private static func read(_ file: String, _ questionSet: EquilibriumQuestionSet) -> QuizQuestionsList<EquilibriumQuestionSet> {
        let headerCols = file.starts(with: "solubility") ? 0 : 1
        return QuizQuestionReader.readOptional(
            from: file,
            questionSet: questionSet,
            headerCols: headerCols
        )!
    }
}
