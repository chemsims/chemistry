//
// Reactions App
//

import Foundation
import ReactionsCore

protocol ReactionRatesInjector {
    var reactionPersistence: ReactionInputPersistence { get }
    var reviewPersistence: ReviewPromptPersistence { get }
    var energyPersistence: EnergyProfilePersistence { get }

    var quizPersistence: AnyQuizPersistence<ReactionsRateQuestionSet> { get }
    var screenPersistence: AnyScreenPersistence<ReactionRatesScreen> { get }
    var appAnalytics: AnyAppAnalytics<ReactionRatesScreen, ReactionsRateQuestionSet> { get }
    var namePersistence: NamePersistence { get }
}

class ProductionReactionRatesInjector: ReactionRatesInjector {

    let reactionPersistence: ReactionInputPersistence = UserDefaultsReactionInputPersistence()

    let quizPersistence: AnyQuizPersistence<ReactionsRateQuestionSet> = AnyQuizPersistence(
        UserDefaultsQuizPersistence<ReactionsRateQuestionSet>(
            prefix: userDefaultsPrefix
        )
    )

    let reviewPersistence: ReviewPromptPersistence = UserDefaultsReviewPromptPersistence()

    let energyPersistence: EnergyProfilePersistence = UserDefaultsEnergyProfilePersistence()

    let screenPersistence = AnyScreenPersistence(
        UserDefaultsScreenPersistence<ReactionRatesScreen>(
            prefix: userDefaultsPrefix
        )
    )

    let appAnalytics = AnyAppAnalytics(
        GoogleAnalytics<ReactionRatesScreen, ReactionsRateQuestionSet>(
            unitName: "reactionRates",
            includeUnitInEventNames: true
        )
    )

    let namePersistence: NamePersistence = UserDefaultsNamePersistence()
}

class InMemoryReactionRatesInjector: ReactionRatesInjector {
    init() { }

    let reactionPersistence: ReactionInputPersistence = InMemoryReactionInputPersistence()

    let quizPersistence: AnyQuizPersistence<ReactionsRateQuestionSet> = AnyQuizPersistence(InMemoryQuizPersistence<ReactionsRateQuestionSet>())

    let reviewPersistence: ReviewPromptPersistence = InMemoryReviewPromptPersistence()

    let energyPersistence: EnergyProfilePersistence = InMemoryEnergyProfilePersistence()

    let screenPersistence = AnyScreenPersistence(
        UserDefaultsScreenPersistence<ReactionRatesScreen>(
            prefix: userDefaultsPrefix
        )
    )

    let appAnalytics = AnyAppAnalytics(NoOpAppAnalytics<ReactionRatesScreen, ReactionsRateQuestionSet>())

    let namePersistence: NamePersistence = InMemoryNamePersistence.shared
}

// We use a blank prefix, since we decided to bundle all units into one app after releasing the
// reaction rates app. Rather than perform a migration, we can simply read from the existing fields.
private let userDefaultsPrefix = ""
