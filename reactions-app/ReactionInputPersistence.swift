//
// Reactions App
//
  

import Foundation

protocol ReactionInputPersistence {

    func save(input: ReactionInput, order: ReactionOrder)
    func get(order: ReactionOrder) -> ReactionInput?

    func setCompleted(screen: AppScreen)
    func hasCompleted(screen: AppScreen) -> Bool

}

class InMemoryReactionInputPersistence: ReactionInputPersistence {

    private var underlying = [ReactionOrder:ReactionInput]()

    private var underlyingScreenCompletions = Set<AppScreen>()

    func save(input: ReactionInput, order: ReactionOrder) {
        underlying[order] = input
    }

    func get(order: ReactionOrder) -> ReactionInput? {
        underlying[order]
    }

    func setCompleted(screen: AppScreen) {
        underlyingScreenCompletions.insert(screen)
    }

    func hasCompleted(screen: AppScreen) -> Bool {
        underlyingScreenCompletions.contains(screen)
    }

}
