//
// Reactions App
//

import Foundation
import ReactionsCore

extension QuizQuestionsList where QuestionSet == EquilibriumQuestionSet {
    static let aqueous = EquilibriumQuizQuestions.getQuestion(.aqueous)
    static let gaseous = EquilibriumQuizQuestions.getQuestion(.gaseous)
    static let solubility = EquilibriumQuizQuestions.getQuestion(.solubility)
}

struct EquilibriumQuizQuestions {
    private init() { }

    private static var isLoaded = false

    /// Loads all quiz questions into memory
    static func load() {
        aqueous = read("aqueous-quiz", .aqueous)
        gaseous = read("gaseous-quiz", .gaseous)
        solubility = read("solubility-quiz", .solubility)
    }

    fileprivate static func getQuestion(
        _ questionSet: EquilibriumQuestionSet
    ) -> QuizQuestionsList<EquilibriumQuestionSet> {
        if !isLoaded {
            load()
        }

        switch questionSet {
        case .aqueous: return aqueous
        case .gaseous: return gaseous
        case .solubility: return solubility
        }
    }

    private static var aqueous: QuizQuestionsList<EquilibriumQuestionSet>!
    private static var gaseous: QuizQuestionsList<EquilibriumQuestionSet>!
    private static var solubility: QuizQuestionsList<EquilibriumQuestionSet>!

    private static func read(_ file: String, _ questionSet: EquilibriumQuestionSet) -> QuizQuestionsList<EquilibriumQuestionSet> {
        QuizQuestionReader.readOptional(
            from: file,
            questionSet: questionSet,
            headerCols: 1,
            bundle: .equilibrium
        )!
    }
}
