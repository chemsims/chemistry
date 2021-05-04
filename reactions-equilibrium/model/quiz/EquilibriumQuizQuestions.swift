//
// Reactions App
//

import Foundation
import ReactionsCore

extension QuizQuestionsList where QuestionSet == EquilibriumQuestionSet {

    static let aqueous = read("dummy-quiz", .aqueous)
    static let gaseous = read("dummy-quiz", .gaseous)
    static let solubility = read("dummy-quiz", .solubility)

    private static func read(_ file: String, _ questionSet: EquilibriumQuestionSet) -> QuizQuestionsList<EquilibriumQuestionSet> {
        QuizQuestionReader.readOptional(from: file, questionSet: questionSet)!
    }
}
