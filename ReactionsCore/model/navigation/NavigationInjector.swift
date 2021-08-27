//
// Reactions App
//

import Foundation

public protocol NavigationInjector {
    associatedtype Screen: Hashable
    associatedtype QuestionSet
    associatedtype Behaviour: NavigationBehaviour where Behaviour.Screen == Screen
    associatedtype Persistence: ScreenPersistence where Persistence.Screen == Screen
    associatedtype Analytics: AppAnalytics where Analytics.Screen == Screen, Analytics.QuestionSet == QuestionSet
    associatedtype QuizP: QuizPersistence where QuizP.QuestionSet == QuestionSet

    var behaviour: Behaviour { get }

    var persistence: Persistence { get }

    var analytics: Analytics { get }

    var allScreens: [Screen] { get }

    var linearScreens: [Screen] { get }

    var quizPersistence: QuizP { get }

    var reviewPersistence: ReviewPromptPersistence { get }

    var namePersistence: NamePersistence { get }

    var sharePrompter: SharePrompter { get }

    var appLaunchPersistence: AppLaunchPersistence { get }
}

public class AnyNavigationInjector<Screen: Hashable, QuestionSet>: NavigationInjector {
    public init(
        behaviour: AnyNavigationBehavior<Screen>,
        persistence: AnyScreenPersistence<Screen>,
        analytics: AnyAppAnalytics<Screen, QuestionSet>,
        quizPersistence: AnyQuizPersistence<QuestionSet>,
        reviewPersistence: ReviewPromptPersistence,
        namePersistence: NamePersistence,
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        allScreens: [Screen],
        linearScreens: [Screen]
    ) {
        self.allScreens = allScreens
        self.linearScreens = linearScreens
        self.behaviour = behaviour
        self.persistence = persistence
        self.analytics = analytics
        self.quizPersistence = quizPersistence
        self.reviewPersistence = reviewPersistence
        self.namePersistence = namePersistence
        self.sharePrompter = sharePrompter
        self.appLaunchPersistence = appLaunchPersistence
    }

    public let allScreens: [Screen]
    public let linearScreens: [Screen]
    public let behaviour: AnyNavigationBehavior<Screen>
    public let persistence: AnyScreenPersistence<Screen>
    public let analytics: AnyAppAnalytics<Screen, QuestionSet>
    public let quizPersistence: AnyQuizPersistence<QuestionSet>
    public let reviewPersistence: ReviewPromptPersistence
    public var namePersistence: NamePersistence
    public let sharePrompter: SharePrompter
    public let appLaunchPersistence: AppLaunchPersistence
}
