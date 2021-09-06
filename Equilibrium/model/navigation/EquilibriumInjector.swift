//
// Reactions App
//

import Foundation
import ReactionsCore

protocol EquilibriumInjector {
    var screenPersistence: AnyScreenPersistence<EquilibriumScreen> { get }
    var analytics: AnyAppAnalytics<EquilibriumScreen, EquilibriumQuestionSet> { get }
    var quizPersistence: AnyQuizPersistence<EquilibriumQuestionSet> { get }
    var solubilityPersistence: SolubilityPersistence { get }
    var reviewPersistence: ReviewPromptPersistence { get }
    var namePersistence: NamePersistence { get }
}

class InMemoryEquilibriumInjector: EquilibriumInjector {

    let solubilityPersistence: SolubilityPersistence = InMemorySolubilityPersistence()

    let screenPersistence = AnyScreenPersistence(UserDefaultsScreenPersistence<EquilibriumScreen>(prefix: userDefaultsPrefix))

    let analytics = AnyAppAnalytics(NoOpAppAnalytics<EquilibriumScreen, EquilibriumQuestionSet>())

    let quizPersistence: AnyQuizPersistence<EquilibriumQuestionSet> = AnyQuizPersistence(InMemoryQuizPersistence())

    let reviewPersistence: ReviewPromptPersistence = InMemoryReviewPromptPersistence()

    let namePersistence: NamePersistence = InMemoryNamePersistence.shared
}

class ProductionEquilibriumInjector: EquilibriumInjector {

    let screenPersistence = AnyScreenPersistence(
        UserDefaultsScreenPersistence<EquilibriumScreen>(
            prefix: userDefaultsPrefix
        )
    )

    let analytics: AnyAppAnalytics<EquilibriumScreen, EquilibriumQuestionSet> =
        AnyAppAnalytics(
            GoogleAnalytics<EquilibriumScreen, EquilibriumQuestionSet>(
                unitName: "equilibrium"
            )
        )

    let quizPersistence: AnyQuizPersistence<EquilibriumQuestionSet> =
        AnyQuizPersistence(
            UserDefaultsQuizPersistence<EquilibriumQuestionSet>(
                prefix: userDefaultsPrefix
            )
        )

    // NB we don't currently need to maintain this between app launches
    // so we use in-memory in production
    let solubilityPersistence: SolubilityPersistence = InMemorySolubilityPersistence()

    let reviewPersistence: ReviewPromptPersistence = UserDefaultsReviewPromptPersistence()

    let namePersistence: NamePersistence = UserDefaultsNamePersistence()
}

private let userDefaultsPrefix = "equilibrium"
