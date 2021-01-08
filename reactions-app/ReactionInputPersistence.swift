//
// Reactions App
//
  

import Foundation

protocol ReactionInputPersistence {

    func save(input: ReactionInput, order: ReactionOrder, reaction: ReactionType)
    func get(order: ReactionOrder, reaction: ReactionType) -> ReactionInput?

    func setCompleted(screen: AppScreen)
    func hasCompleted(screen: AppScreen) -> Bool

    func hasIdentifiedReactionOrders() -> Bool
    func setHasIdentifiedReactionOrders()
}

extension ReactionInputPersistence {
    var hasCompletedApp: Bool {
        hasCompleted(screen: .energyProfileQuiz)
    }
}

class InMemoryReactionInputPersistence: ReactionInputPersistence {

    private var underlying = [ReactionInputKey:ReactionInput]()

    private var underlyingScreenCompletions = Set<AppScreen>()

    private var _hasIdentifiedReactionOrders = false

    func save(input: ReactionInput, order: ReactionOrder, reaction: ReactionType) {
        let key = ReactionInputKey(order: order, type: reaction)
        underlying[key] = input
    }

    func get(order: ReactionOrder, reaction: ReactionType) -> ReactionInput? {
        let key = ReactionInputKey(order: order, type: reaction)
        return underlying[key]
    }

    func setCompleted(screen: AppScreen) {
        underlyingScreenCompletions.insert(screen)
    }

    func hasCompleted(screen: AppScreen) -> Bool {
        underlyingScreenCompletions.contains(screen)
    }

    func hasIdentifiedReactionOrders() -> Bool {
        _hasIdentifiedReactionOrders
    }

    func setHasIdentifiedReactionOrders() {
        _hasIdentifiedReactionOrders = true
    }

    fileprivate struct ReactionInputKey: Hashable {
        let order: ReactionOrder
        let type: ReactionType
    }

}
