//
// Reactions App
//

import Foundation

public protocol AppAnalytics {
    associatedtype Screen
    associatedtype QuestionSet

    func opened(screen: Screen)

    var enabled: Bool { get }
    func setEnabled(value: Bool)

    func answeredQuestion(
        questionSet: QuestionSet,
        questionId: String,
        answerId: String,
        answerAttempt: Int,
        isCorrect: Bool
    )

    func startedQuiz(questionSet: QuestionSet, difficulty: QuizDifficulty)

    func completedQuiz(
        questionSet: QuestionSet,
        difficulty: QuizDifficulty,
        percentCorrect: Double
    )


}

public class AnyAppAnalytics<Screen, QuestionSet>: AppAnalytics {

    public init<Analytics: AppAnalytics>(_ analytics: Analytics) where Analytics.Screen == Screen, Analytics.QuestionSet == QuestionSet {
        self._opened = analytics.opened
        self._getEnabled = { analytics.enabled }
        self._setEnabled = analytics.setEnabled
        self._answeredQuestion = analytics.answeredQuestion
        self._startedQuiz = analytics.startedQuiz
        self._completedQuiz = analytics.completedQuiz
    }

    private let _opened: (Screen) -> Void
    private let _getEnabled: () -> Bool
    private let _setEnabled: (Bool) -> Void
    private let _answeredQuestion: (QuestionSet, String, String, Int, Bool) -> Void
    private let _startedQuiz: (QuestionSet, QuizDifficulty) -> Void
    private let _completedQuiz: (QuestionSet, QuizDifficulty, Double) -> Void

    public func opened(screen: Screen) {
        _opened(screen)
    }

    public var enabled: Bool {
        _getEnabled()
    }

    public func setEnabled(value: Bool) {
        _setEnabled(value)
    }

    public func answeredQuestion(
        questionSet: QuestionSet,
        questionId: String,
        answerId: String,
        answerAttempt: Int,
        isCorrect: Bool
    ) {
        _answeredQuestion(questionSet, questionId, answerId, answerAttempt, isCorrect)
    }

    public func startedQuiz(
        questionSet: QuestionSet,
        difficulty: QuizDifficulty
    ) {
        _startedQuiz(questionSet, difficulty)
    }

    public func completedQuiz(
        questionSet: QuestionSet,
        difficulty: QuizDifficulty,
        percentCorrect: Double
    ) {
        _completedQuiz(questionSet, difficulty, percentCorrect)
    }
}

public class NoOpAppAnalytics<Screen, QuestionSet>: AppAnalytics {
    public init() { }
    
    public func opened(screen: Screen) { }

    private(set) public var enabled: Bool = false

    public func setEnabled(value: Bool) {
        enabled = value
    }

    public func startedQuiz(questionSet: QuestionSet, difficulty: QuizDifficulty) {
    }

    public func answeredQuestion(
        questionSet: QuestionSet,
        questionId: String,
        answerId: String,
        answerAttempt: Int,
        isCorrect: Bool
    ) {
    }

    public func completedQuiz(
        questionSet: QuestionSet,
        difficulty: QuizDifficulty,
        percentCorrect: Double
    ) {
    }
}
