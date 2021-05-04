//
// Reactions App
//

import Foundation
import ReactionsCore

protocol EquilibriumInjector {
    var persistence: AnyScreenPersistence<EquilibriumAppScreen> { get }
    var screenAnalytics: AnyAppAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet> { get }
    var quizPersistence: AnyQuizPersistence<EquilibriumQuestionSet> { get }
}

class InMemoryEquilibriumInjector: EquilibriumInjector {

    init() {
        print("Using in mem")
    }

    let persistence = AnyScreenPersistence(InMemoryScreenPersistence<EquilibriumAppScreen>())

    let screenAnalytics = AnyAppAnalytics(NoOpAppAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet>())

    let quizPersistence: AnyQuizPersistence<EquilibriumQuestionSet> = AnyQuizPersistence(InMemoryQuizPersistence())
}

class ProductionEquilibriumInjector: EquilibriumInjector {

    init() {
        print("Using prod")
    }

    let persistence = AnyScreenPersistence(UserDefaultsScreenPersistence<EquilibriumAppScreen>())

    let screenAnalytics: AnyAppAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet> =
        AnyAppAnalytics(GoogleAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet>())

    let quizPersistence: AnyQuizPersistence<EquilibriumQuestionSet> =
        AnyQuizPersistence(UserDefaultsQuizPersistence<EquilibriumQuestionSet>())
}
