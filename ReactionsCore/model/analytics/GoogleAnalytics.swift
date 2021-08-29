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

extension GoogleAnalytics: AppAnalytics, GeneralAppAnalytics {

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

// MARK: - Prompts
extension GoogleAnalytics {
    private func promptAction(event: String, count: Int) {
        Analytics.logEvent(event, parameters: [Params.promptCount: count])
    }
}

// MARK: - Sharing
extension GoogleAnalytics {

    public func tappedShareFromMenu() {
        Analytics.logEvent(Events.tappedShareFromMenu, parameters: nil)
    }

    public func showedSharePrompt(promptCount: Int) {
        promptAction(event: Events.showedSharePrompt, count: promptCount)
    }

    public func tappedShareFromPrompt(promptCount: Int) {
        promptAction(event: Events.tappedShareFromPrompt, count: promptCount)
    }

    public func dismissedSharePrompt(promptCount: Int) {
        promptAction(event: Events.dismissedSharePrompt, count: promptCount)
    }
}

// MARK: - Tips
extension GoogleAnalytics {
    public func showedTipPrompt(promptCount: Int) {
        promptAction(event: Events.showedTipPrompt, count: promptCount)
    }

    public func dismissedTipPrompt(promptCount: Int) {
        promptAction(event: Events.dismissedTipPrompt, count: promptCount)
    }

    public func beganUnlockBadgePurchaseFromTipPrompt(promptCount: Int, productId: String) {
        Analytics.logEvent(
            Events.beganUnlockBadgePurchaseFromTipPrompt,
            parameters: [
                Params.promptCount: promptCount,
                Params.productId: productId
            ]
        )
    }

    public func beganUnlockBadgePurchaseFromMenu(productId: String) {
        Analytics.logEvent(
            Events.beganUnlockBadgePurchaseFromMenu,
            parameters: [
                Params.productId: productId
            ]
        )
    }
}

// MARK: - Review prompt
extension GoogleAnalytics {
    public func attemptedReviewPrompt(promptCount: Int) {
        promptAction(event: Events.attemptedReviewPrompt, count: promptCount)
    }
}

// MARK: - Onboarding
extension GoogleAnalytics {
    public func completedOnboardingWithName() {
        Analytics.logEvent(Events.completedOnboardingWithName, parameters: nil)
    }

    public func completedOnboardingWithoutName() {
        Analytics.logEvent(Events.completedOnboardingWithoutName, parameters: nil)
    }
}

private struct Events {
    // Quiz
    static let answeredQuestion = "answeredQuestion"
    static let startedQuiz = "startedQuiz"
    static let completedQuiz = "completedQuiz"

    // Tips
    static let showedTipPrompt = "showedTipPrompt"
    static let dismissedTipPrompt = "dismissedTipPrompt"
    static let beganUnlockBadgePurchaseFromTipPrompt = "beganUnlockBadgePurchaseFromTipPrompt"
    static let beganUnlockBadgePurchaseFromMenu = "beganUnlockBadgePurchaseFromMenu"

    // Sharing
    static let showedSharePrompt = "showedSharePrompt"
    static let dismissedSharePrompt = "dismissedSharePrompt"
    static let tappedShareFromMenu = "tappedShareFromMenu"
    static let tappedShareFromPrompt = "tappedShareFromPrompt"

    // Reviews
    static let attemptedReviewPrompt = "attemptedReviewPrompt"

    // Onboarding
    static let completedOnboardingWithName = "completedOnboardingWithName"
    static let completedOnboardingWithoutName = "completedOnboardingWithoutName"
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

    static let promptCount = "promptCount"
    static let productId = "productId"
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
