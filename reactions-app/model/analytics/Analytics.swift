//
// Reactions App
//
  

import Foundation
import FirebaseAnalytics

protocol AnalyticsService {
    func openedScreen(_ screen: AppScreen)

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

class NoOpAnalytics: AnalyticsService {
    func openedScreen(_ screen: AppScreen) { }
    func startedQuiz(questionSet: QuestionSet, difficulty: QuizDifficulty) { }
    func answeredQuestion(questionSet: QuestionSet, questionId: String, answerId: String, answerAttempt: Int, isCorrect: Bool) { }
    func completedQuiz(questionSet: QuestionSet, difficulty: QuizDifficulty, percentCorrect: Double) { }
}

struct GoogleAnalytics: AnalyticsService {

    func openedScreen(_ screen: AppScreen) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screen.rawValue,
        ])
    }

    func answeredQuestion(
        questionSet: QuestionSet,
        questionId: String,
        answerId: String,
        answerAttempt: Int,
        isCorrect: Bool
    ) {
        Analytics.logEvent(Events.answeredQuestion, parameters: [
            Params.questionSet: questionSet.rawValue,
            Params.questionId: questionId,
            Params.answerId: answerId,
            Params.answerAttempt: answerAttempt,
            Params.isCorrect: isCorrect
        ])
    }

    func startedQuiz(questionSet: QuestionSet, difficulty: QuizDifficulty) {
        Analytics.logEvent(Events.startedQuiz, parameters: [
            Params.questionSet: questionSet.rawValue,
            Params.quizDifficulty: difficulty.displayName.lowercased()
        ])
    }

    func completedQuiz(
        questionSet: QuestionSet,
        difficulty: QuizDifficulty,
        percentCorrect: Double
    ) {
        Analytics.logEvent(Events.completedQuiz, parameters: [
            Params.questionSet: questionSet.rawValue,
            Params.quizDifficulty: difficulty.displayName.lowercased(),
            Params.percentCorrect: percentCorrect
        ])
    }

    private struct Events {
        static let answeredQuestion = "answeredQuestion"
        static let startedQuiz = "startedQuiz"
        static let completedQuiz = "completedQuiz"
    }

    private struct Params {
        static let questionSet = "questionSet"

        static let questionId = "questionId"
        static let answerId = "answerId"
        static let answerAttempt = "answerAttempt"
        static let isCorrect = "isCorrect"

        static let quizScreen = "quizScreen"
        static let quizDifficulty = "quizDifficulty"

        static let percentCorrect = "percentCorrect"
    }
}
