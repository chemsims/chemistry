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
        print("Started read at \(mach_absolute_time())")
        aqueous = read("aqueous-quiz", .aqueous)
        gaseous = read("gaseous-quiz", .gaseous)
        solubility = read("solubility-quiz", .solubility)
        print("Ended read at \(mach_absolute_time())")
    }

    private(set) fileprivate static var aqueous: QuizQuestionsList<EquilibriumQuestionSet>!
    private(set) fileprivate static var gaseous: QuizQuestionsList<EquilibriumQuestionSet>!
    private(set) fileprivate static var solubility: QuizQuestionsList<EquilibriumQuestionSet>!

    private static func read(_ file: String, _ questionSet: EquilibriumQuestionSet) -> QuizQuestionsList<EquilibriumQuestionSet> {
        QuizQuestionReader.readOptional(from: file, questionSet: questionSet)!
    }
}
