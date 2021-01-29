//
// Reactions App
//
  

import Foundation

protocol Injector {
    var reactionPersistence: ReactionInputPersistence { get }
    var quizPersistence: QuizPersistence { get }
    var reviewPersistence: ReviewPromptPersistence { get }
    var energyPersistence: EnergyProfilePersistence { get }
}

class ProductionInjector: Injector {

    let reactionPersistence: ReactionInputPersistence = InMemoryReactionInputPersistence()

    let quizPersistence: QuizPersistence = UserDefaultsQuizPersistence()

    let reviewPersistence: ReviewPromptPersistence = InMemoryReviewPromptPersistence()

    let energyPersistence: EnergyProfilePersistence = InMemoryEnergyProfilePersistence()
}

class InMemoryInjector: Injector {
    private init() { }
    static let shared = InMemoryInjector()

    let reactionPersistence: ReactionInputPersistence = InMemoryReactionInputPersistence()

    let quizPersistence: QuizPersistence = InMemoryQuizPersistence()

    let reviewPersistence: ReviewPromptPersistence = InMemoryReviewPromptPersistence()

    let energyPersistence: EnergyProfilePersistence = InMemoryEnergyProfilePersistence()
}
