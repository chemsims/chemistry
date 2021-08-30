//
// Reactions App
//

import Foundation
import ReactionsCore

extension QuizQuestionsList where QuestionSet == AcidBasesQuestionSet {
    static let introduction = AcidQuizQuestions.getQuestion(.introduction)
    static let buffer  = AcidQuizQuestions.getQuestion(.buffer)
    static let titration = AcidQuizQuestions.getQuestion(.titration)
}

public struct AcidQuizQuestions {
    private init() { }


    private static var isLoaded = false

    /// Loads all quiz questions into memory
    public static func load() {
        guard !isLoaded else {
            return
        }
        introduction = read("introduction-quiz", .introduction)
        buffer = read("buffer-quiz", .introduction)
        titration = read("titration-quiz", .introduction)
        isLoaded = true
    }

    fileprivate static func getQuestion(_ questionSet: AcidBasesQuestionSet) -> QuizQuestionsList<AcidBasesQuestionSet> {
        if !isLoaded {
            load()
        }
        switch questionSet {
        case .introduction: return introduction
        case .buffer: return buffer
        case .titration: return titration
        }
    }

    private static var introduction: QuizQuestionsList<AcidBasesQuestionSet>!

    private static var buffer: QuizQuestionsList<AcidBasesQuestionSet>!

    private static var titration: QuizQuestionsList<AcidBasesQuestionSet>!

    private static func read(_ file: String, _ questionSet: AcidBasesQuestionSet) -> QuizQuestionsList<AcidBasesQuestionSet> {
        QuizQuestionReader.readOptional(
            from: file,
            questionSet: questionSet,
            headerCols: 1,
            bundle: .acidBases
        )!
    }
}
