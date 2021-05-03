//
// Reactions App
//

import Foundation

public class AnyQuizPersistence<QuestionSet>: QuizPersistence {

    public init<QP: QuizPersistence>(_ underlying: QP) where QP.QuestionSet == QuestionSet {
        self._save = underlying.saveAnswers
        self._get = underlying.getAnswers
    }

    private let _save: (SavedQuiz<QuestionSet>, [QuizQuestion]) -> Void
    private let _get: (QuestionSet, [QuizQuestion]) -> SavedQuiz<QuestionSet>?

    public func saveAnswers(quiz: SavedQuiz<QuestionSet>, questions: [QuizQuestion]) {
        _save(quiz, questions)
    }

    public func getAnswers(questionSet: QuestionSet, questions: [QuizQuestion]) -> SavedQuiz<QuestionSet>? {
        _get(questionSet, questions)
    }
}
