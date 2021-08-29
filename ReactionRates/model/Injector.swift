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
    var namePersistence: NamePersistence { get }
}

class ProductionInjector: Injector {

    let reactionPersistence: ReactionInputPersistence = UserDefaultsReactionInputPersistence()

    let quizPersistence: AnyQuizPersistence<ReactionsRateQuestionSet> = AnyQuizPersistence(
        UserDefaultsQuizPersistence<ReactionsRateQuestionSet>(
            prefix: userDefaultsPrefix
        )
    )

    let reviewPersistence: ReviewPromptPersistence = UserDefaultsReviewPromptPersistence()

    let energyPersistence: EnergyProfilePersistence = UserDefaultsEnergyProfilePersistence()

    let screenPersistence = AnyScreenPersistence(
        UserDefaultsScreenPersistence<AppScreen>(
            prefix: userDefaultsPrefix
        )
    )

    let appAnalytics = AnyAppAnalytics(
        GoogleAnalytics<AppScreen, ReactionsRateQuestionSet>(
            unitName: "reactionRates",
            includeUnitInEventNames: true
        )
    )

    let namePersistence: NamePersistence = UserDefaultsNamePersistence()
}

class InMemoryInjector: Injector {
    init() { }

    let reactionPersistence: ReactionInputPersistence = InMemoryReactionInputPersistence()

    let quizPersistence: AnyQuizPersistence<ReactionsRateQuestionSet> = AnyQuizPersistence(InMemoryQuizPersistence<ReactionsRateQuestionSet>())

    let reviewPersistence: ReviewPromptPersistence = InMemoryReviewPromptPersistence()

    let energyPersistence: EnergyProfilePersistence = InMemoryEnergyProfilePersistence()

    let screenPersistence = AnyScreenPersistence(InMemoryScreenPersistence<AppScreen>(completedAllScreens: false))

    let appAnalytics = AnyAppAnalytics(NoOpAppAnalytics<AppScreen, ReactionsRateQuestionSet>())

    let namePersistence: NamePersistence = InMemoryNamePersistence()
}

// We use a blank prefix, since we decided to bundle all units into one after releasing the reaction
// rates app. Rather than perform a migration, we can simply read from the existing fields.
private let userDefaultsPrefix = ""
