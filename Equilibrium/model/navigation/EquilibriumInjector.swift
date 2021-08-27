//
// Reactions App
//

import Foundation
import ReactionsCore

protocol EquilibriumInjector {
    var screenPersistence: AnyScreenPersistence<EquilibriumAppScreen> { get }
    var analytics: AnyAppAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet> { get }
    var quizPersistence: AnyQuizPersistence<EquilibriumQuestionSet> { get }
    var solubilityPersistence: SolubilityPersistence { get }
    var reviewPersistence: ReviewPromptPersistence { get }
    var namePersistence: NamePersistence { get }
}

class InMemoryEquilibriumInjector: EquilibriumInjector {

    let solubilityPersistence: SolubilityPersistence = InMemorySolubilityPersistence()

    let screenPersistence = AnyScreenPersistence(NoOpScreenPersistence<EquilibriumAppScreen>())

    let analytics = AnyAppAnalytics(NoOpAppAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet>())

    let quizPersistence: AnyQuizPersistence<EquilibriumQuestionSet> = AnyQuizPersistence(InMemoryQuizPersistence())

    let reviewPersistence: ReviewPromptPersistence = InMemoryReviewPromptPersistence()

    let namePersistence: NamePersistence = InMemoryNamePersistence()
}

class ProductionEquilibriumInjector: EquilibriumInjector {

    let screenPersistence = AnyScreenPersistence(
        UserDefaultsScreenPersistence<EquilibriumAppScreen>(
            prefix: userDefaultsPrefix
        )
    )

    let analytics: AnyAppAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet> =
        AnyAppAnalytics(
            GoogleAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet>(
                unitName: "equilibrium"
            )
        )

    let quizPersistence: AnyQuizPersistence<EquilibriumQuestionSet> =
        AnyQuizPersistence(
            UserDefaultsQuizPersistence<EquilibriumQuestionSet>(
                prefix: userDefaultsPrefix
            )
        )

    let solubilityPersistence: SolubilityPersistence = InMemorySolubilityPersistence()

    let reviewPersistence: ReviewPromptPersistence = UserDefaultsReviewPromptPersistence()

    let namePersistence: NamePersistence = UserDefaultsNamePersistence()
}

private let userDefaultsPrefix = "equilibrium"
