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
            AnalyticsParameterScreenName: screen.rawValue
        ])
    }

    func startedQuiz(questionSet: QuestionSet, difficulty: QuizDifficulty) {
        let eventName = "\(Events.startedQuiz)\(questionSet.eventNameSuffix)"
        Analytics.logEvent(eventName, parameters: [
            Params.quizDifficulty: difficulty.displayName.lowercased()
        ])
    }

    func answeredQuestion(
        questionSet: QuestionSet,
        questionId: String,
        answerId: String,
        answerAttempt: Int,
        isCorrect: Bool
    ) {
        let sanitisedId = questionId.replacingOccurrences(of: "-", with: "_")
        let eventName = "\(Events.answeredQuestion)_\(sanitisedId)"
        Analytics.logEvent(eventName, parameters: [
            Params.questionSet: questionSet.rawValue,
            Params.answerId: answerId,
            Params.answerAttempt: answerAttempt,
            Params.answerAttemptDimension: "_\(answerAttempt)",
            Params.isCorrect: isCorrect,
            Params.isCorrectDimension: isCorrect ? "YES" : "NO"
        ])
    }

    func completedQuiz(
        questionSet: QuestionSet,
        difficulty: QuizDifficulty,
        percentCorrect: Double
    ) {
        let eventName = "\(Events.completedQuiz)\(questionSet.eventNameSuffix)"
        Analytics.logEvent(eventName, parameters: [
            Params.quizDifficulty: difficulty.displayName.lowercased(),
            Params.percentCorrect: percentCorrect,
            Params.percentCorrectDimension: "_\(percentCorrect.str(decimals: 0))"
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
        static let answerAttemptDimension = "answerAttemptDimension"

        static let isCorrect = "isCorrect"
        static let isCorrectDimension = "isCorrectDimension"

        static let quizScreen = "quizScreen"
        static let quizDifficulty = "quizDifficulty"

        static let percentCorrect = "percentCorrect"
        static let percentCorrectDimension = "percentCorrectDimension"
    }
}

extension QuestionSet {
    var eventNameSuffix: String {
        self.rawValue.prefix(1).capitalized + self.rawValue.dropFirst()
    }
}
