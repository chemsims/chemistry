//
// Reactions App
//

import ReactionsCore
import Foundation

public enum ChemicalReactionsQuestionSet: String {
    case balancedReactions,
         limitingReagent,
         precipitation
}

extension QuizQuestionsList where QuestionSet == ChemicalReactionsQuestionSet {
    static let balancedReactions = ChemicalReactionsQuizQuestions.getQuestion(.balancedReactions)
    static let limitingReagent  = ChemicalReactionsQuizQuestions.getQuestion(.limitingReagent)
    static let precipitation = ChemicalReactionsQuizQuestions.getQuestion(.precipitation)
}

public struct ChemicalReactionsQuizQuestions {
    private init() { }

    private static var isLoaded = false

    /// Loads all quiz questions into memory
    public static func load() {
        guard !isLoaded else {
            return
        }
        balancedReactions = read("balanced-reaction-quiz", .balancedReactions)
        limitingReagent = read("limiting-reagent-quiz", .limitingReagent)
        precipitation = read("precipitation-quiz", .precipitation)
        isLoaded = true
    }

    fileprivate static func getQuestion(
        _ questionSet: ChemicalReactionsQuestionSet
    ) -> QuizQuestionsList<ChemicalReactionsQuestionSet> {
        if !isLoaded {
            load()
        }
        switch questionSet {
        case .balancedReactions: return balancedReactions
        case .limitingReagent: return limitingReagent
        case .precipitation: return precipitation
        }
    }

    private static var balancedReactions: QuizQuestionsList<ChemicalReactionsQuestionSet>!

    private static var limitingReagent: QuizQuestionsList<ChemicalReactionsQuestionSet>!

    private static var precipitation: QuizQuestionsList<ChemicalReactionsQuestionSet>!

    private static func read(_ file: String, _ questionSet: ChemicalReactionsQuestionSet) -> QuizQuestionsList<ChemicalReactionsQuestionSet> {
        QuizQuestionReader.readOptional(
            from: file,
            questionSet: questionSet,
            headerCols: 1,
            bundle: .chemicalReactions
        )!
    }
}
