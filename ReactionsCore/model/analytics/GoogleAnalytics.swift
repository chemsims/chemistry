//
// Reactions App
//

import Foundation

public struct GoogleAnalytics<Screen: RawRepresentable, QuestionSet: RawRepresentable>
where Screen.RawValue == String, QuestionSet.RawValue == String {

    let client: GoogleAnalyticsClient
    public init(client: GoogleAnalyticsClient) {
        self.client = client
        userDefaults.register(defaults: [
            analyticsEnabledKey: true
        ])
        setAnalyticsCollection(enabled)
    }

    private let userDefaults = UserDefaults.standard
    private let analyticsEnabledKey = "analyticsEnabled"

    private func setAnalyticsCollection(_ value: Bool) {
        client.setAnalyticsCollectionEnabled(value)
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
        client.logEvent(client.eventScreenView, parameters: [
            client.parameterScreenName: screen.rawValue
        ])
    }

    public func startedQuiz(questionSet: QuestionSet, difficulty: QuizDifficulty) {
        let eventName = "\(Events.startedQuiz)\(questionSet.eventNameSuffix)"
        client.logEvent(eventName, parameters: [
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
        let sanitisedId = questionId.replacingOccurrences(of: "-", with: "_")
        let eventName = "\(Events.answeredQuestion)_\(sanitisedId)"
        client.logEvent(eventName, parameters: [
            Params.questionSet: questionSet.rawValue,
            Params.answerId: answerId,
            Params.answerAttempt: answerAttempt,
            Params.answerAttemptDimension: "_\(answerAttempt)",
            Params.isCorrect: isCorrect,
            Params.isCorrectDimension: isCorrect ? "YES" : "NO"
        ])
    }

    public func completedQuiz(
        questionSet: QuestionSet,
        difficulty: QuizDifficulty,
        percentCorrect: Double
    ) {
        let eventName = "\(Events.completedQuiz)\(questionSet.eventNameSuffix)"
        client.logEvent(eventName, parameters: [
            Params.quizDifficulty: difficulty.displayName.lowercased(),
            Params.percentCorrect: percentCorrect,
            Params.percentCorrectDimension: "_\(percentCorrect.str(decimals: 0))"
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

    static let percentCorrect = "percentCorrect"
    static let percentCorrectDimension = "percentCorrectDimension"
}

public protocol GoogleAnalyticsClient {
    func setAnalyticsCollectionEnabled(_ enabled: Bool)
    func logEvent(_ name: String, parameters: [String : Any]?)

    var eventScreenView: String { get }
    var parameterScreenName: String { get }
}

private extension RawRepresentable where RawValue == String {
    var eventNameSuffix: String {
        self.rawValue.prefix(1).capitalized + self.rawValue.dropFirst()
    }
}
