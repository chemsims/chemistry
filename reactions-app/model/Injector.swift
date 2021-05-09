//
// Reactions App
//

import Foundation
import ReactionsCore

protocol Injector {
    var reactionPersistence: ReactionInputPersistence { get }
    var reviewPersistence: ReviewPromptPersistence { get }
    var energyPersistence: EnergyProfilePersistence { get }

    var quizPersistence: AnyQuizPersistence<ReactionsRateQuestionSet> { get }
    var screenPersistence: AnyScreenPersistence<AppScreen> { get }
    var appAnalytics: AnyAppAnalytics<AppScreen, ReactionsRateQuestionSet> { get }
}

class ProductionInjector: Injector {

    let reactionPersistence: ReactionInputPersistence = UserDefaultsReactionInputPersistence()

    let quizPersistence: AnyQuizPersistence<ReactionsRateQuestionSet> = AnyQuizPersistence(InMemoryQuizPersistence<ReactionsRateQuestionSet>())

    let reviewPersistence: ReviewPromptPersistence = UserDefaultsReviewPromptPersistence()

    let energyPersistence: EnergyProfilePersistence = UserDefaultsEnergyProfilePersistence()

    let screenPersistence = AnyScreenPersistence(UserDefaultsScreenPersistence<AppScreen>())
    let appAnalytics = AnyAppAnalytics(GoogleAnalytics<AppScreen, ReactionsRateQuestionSet>())
}

class InMemoryInjector: Injector {
    init() { }

    let reactionPersistence: ReactionInputPersistence = InMemoryReactionInputPersistence()

    let quizPersistence: AnyQuizPersistence<ReactionsRateQuestionSet> = AnyQuizPersistence(InMemoryQuizPersistence<ReactionsRateQuestionSet>())

    let reviewPersistence: ReviewPromptPersistence = InMemoryReviewPromptPersistence()

    let energyPersistence: EnergyProfilePersistence = InMemoryEnergyProfilePersistence()

    let screenPersistence = AnyScreenPersistence(InMemoryScreenPersistence<AppScreen>())
    let appAnalytics = AnyAppAnalytics(NoOpAppAnalytics<AppScreen, ReactionsRateQuestionSet>())
}
