//
// Reactions App
//

import Foundation

protocol Injector {
    var reactionPersistence: ReactionInputPersistence { get }
    var quizPersistence: QuizPersistence { get }
    var reviewPersistence: ReviewPromptPersistence { get }
    var energyPersistence: EnergyProfilePersistence { get }
    var analytics: AnalyticsService { get }
    var lastOpenedScreenPersistence: LastOpenedScreenPersistence { get }
}

class ProductionInjector: Injector {

    let reactionPersistence: ReactionInputPersistence = UserDefaultsReactionInputPersistence()

    let quizPersistence: QuizPersistence = UserDefaultsQuizPersistence()

    let reviewPersistence: ReviewPromptPersistence = UserDefaultsReviewPromptPersistence()

    let energyPersistence: EnergyProfilePersistence = UserDefaultsEnergyProfilePersistence()

    let analytics: AnalyticsService = GoogleAnalytics()

    let lastOpenedScreenPersistence: LastOpenedScreenPersistence = UserDefaultsLastOpenedScreenPersistence()
}

class InMemoryInjector: Injector {
    init() { }

    let reactionPersistence: ReactionInputPersistence = InMemoryReactionInputPersistence()

    let quizPersistence: QuizPersistence = InMemoryQuizPersistence()

    let reviewPersistence: ReviewPromptPersistence = InMemoryReviewPromptPersistence()

    let energyPersistence: EnergyProfilePersistence = InMemoryEnergyProfilePersistence()

    let analytics: AnalyticsService = NoOpAnalytics()

    let lastOpenedScreenPersistence: LastOpenedScreenPersistence = UserDefaultsLastOpenedScreenPersistence()
}
