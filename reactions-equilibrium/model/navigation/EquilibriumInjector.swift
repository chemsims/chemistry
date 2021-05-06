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
}

class InMemoryEquilibriumInjector: EquilibriumInjector {

    let solubilityPersistence: SolubilityPersistence = InMemorySolubilityPersistence()

    let screenPersistence = AnyScreenPersistence(NoOpScreenPersistence<EquilibriumAppScreen>())

    let analytics = AnyAppAnalytics(NoOpAppAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet>())

    let quizPersistence: AnyQuizPersistence<EquilibriumQuestionSet> = AnyQuizPersistence(InMemoryQuizPersistence())
}

class ProductionEquilibriumInjector: EquilibriumInjector {

    let screenPersistence = AnyScreenPersistence(UserDefaultsScreenPersistence<EquilibriumAppScreen>())

    let analytics: AnyAppAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet> =
        AnyAppAnalytics(GoogleAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet>())

    let quizPersistence: AnyQuizPersistence<EquilibriumQuestionSet> =
        AnyQuizPersistence(UserDefaultsQuizPersistence<EquilibriumQuestionSet>())

    let solubilityPersistence: SolubilityPersistence = InMemorySolubilityPersistence()
}
