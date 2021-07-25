//
// Reactions App
//

import Foundation
import FirebaseAnalytics

public struct GoogleAnalytics<Screen: RawRepresentable, QuestionSet: RawRepresentable>
where
      QuestionSet.RawValue == String,
      Screen : HasAnalyticsLabel {

    public init(unitName: String, includeUnitInEventNames: Bool = true) {
        self.unitName = unitName.sanitisedForAnalytics
        self.includeUnitInEventNames = includeUnitInEventNames
        userDefaults.register(defaults: [
            analyticsEnabledKey: true
        ])
        setAnalyticsCollection(enabled)
    }

    private let unitName: String
    private let includeUnitInEventNames: Bool
    private let userDefaults = UserDefaults.standard
    private let analyticsEnabledKey = "analyticsEnabled"

    private func setAnalyticsCollection(_ value: Bool) {
        Analytics.setAnalyticsCollectionEnabled(value)
    }
}


extension GoogleAnalytics: AppAnalytics {

    public var enabled: Bool {
        userDefaults.bool(forKey: analyticsEnabledKey)
    }

    public func setEnabled(value: Bool) {
        userDefaults.setValue(value, forKey: analyticsEnabledKey)
        setAnalyticsCollection(value)
    }

    public func opened(screen: Screen) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screen.analyticsLabel.sanitisedForAnalytics,
            Params.unit: unitName
        ])
    }

    public func startedQuiz(questionSet: QuestionSet, difficulty: QuizDifficulty) {
        let unitStr = includeUnitInEventNames ? "_\(unitName)_" : ""
        let eventName = "\(Events.startedQuiz)\(unitStr)\(questionSet.eventNameSuffix)"
        Analytics.logEvent(eventName, parameters: [
            Params.quizDifficulty: difficulty.displayName.lowercased()
        ])
    }

    public func answeredQuestion(
        questionSet: QuestionSet,
        questionId: String,
        answerId: String,
        answerAttempt: Int,
        isCorrect: Bool
    ) {
        let sanitisedId = questionId.sanitisedForAnalytics
        let unitStr = includeUnitInEventNames ? "\(unitName)_" : ""
        let eventName = "\(Events.answeredQuestion)_\(unitStr)\(sanitisedId)"
        Analytics.logEvent(eventName, parameters: [
            Params.questionSet: questionSet.rawValue,
            Params.answerId: answerId,
            Params.answerAttempt: answerAttempt,
            Params.answerAttemptDimension: "_\(answerAttempt)",
            Params.isCorrect: isCorrect,
            Params.isCorrectDimension: isCorrect ? "YES" : "NO",
            Params.unit: unitName
        ])
    }

    public func completedQuiz(
        questionSet: QuestionSet,
        difficulty: QuizDifficulty,
        percentCorrect: Double
    ) {
        let unitStr = includeUnitInEventNames ? "_\(unitName)_" : ""
        let eventName = "\(Events.completedQuiz)\(unitStr)\(questionSet.eventNameSuffix)"
        Analytics.logEvent(eventName, parameters: [
            Params.quizDifficulty: difficulty.displayName.lowercased(),
            Params.percentCorrect: percentCorrect,
            Params.percentCorrectDimension: "_\(percentCorrect.str(decimals: 0))",
            Params.unit: unitName
        ])
    }
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
    static let unit = "unit"

    static let percentCorrect = "percentCorrect"
    static let percentCorrectDimension = "percentCorrectDimension"
}

private extension RawRepresentable where RawValue == String {
    var eventNameSuffix: String {
        self.rawValue.prefix(1).capitalized + self.rawValue.dropFirst()
    }
}

private extension String {

    /// Sanitises a string input for analytics.
    /// Google Analytics does not accept hyphens, so these are replaced with underscore.
    var sanitisedForAnalytics: String {
        self.replacingOccurrences(of: "-", with: "_")
    }
}
