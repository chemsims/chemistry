//
// Reactions App
//
  

import Foundation

protocol ReactionInputPersistence {

    func save(input: ReactionInput, order: ReactionOrder)
    func get(order: ReactionOrder) -> ReactionInput?

    func setCompleted(screen: AppScreen)
    func hasCompleted(screen: AppScreen) -> Bool

    func setUsed(catalyst: Catalyst)
    func hasUsed(catalyst: Catalyst) -> Bool

}

class InMemoryReactionInputPersistence: ReactionInputPersistence {

    private var underlying = [ReactionOrder:ReactionInput]()

    private var underlyingScreenCompletions = Set<AppScreen>()

    private var underlyingCatalyst = Set<Catalyst>()

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

    func setUsed(catalyst: Catalyst) {
        underlyingCatalyst.insert(catalyst)
    }

    func hasUsed(catalyst: Catalyst) -> Bool {
        underlyingCatalyst.contains(catalyst)
    }

}
