//
// Reactions App
//
  

import Foundation

protocol ReactionInputPersistence {

    func save(input: ReactionInput, order: ReactionOrder, reaction: OrderedReactionSet)
    func get(order: ReactionOrder, reaction: OrderedReactionSet) -> ReactionInput?

    func setCompleted(screen: AppScreen)
    func hasCompleted(screen: AppScreen) -> Bool

    func setUsed(catalyst: Catalyst)
    func hasUsed(catalyst: Catalyst) -> Bool
}

extension ReactionInputPersistence {
    var hasCompletedApp: Bool {
        hasCompleted(screen: .energyProfileQuiz)
    }
}

class InMemoryReactionInputPersistence: ReactionInputPersistence {

    private var underlying = [ReactionInputKey:ReactionInput]()

    private var underlyingScreenCompletions = Set<AppScreen>()

    private var underlyingCatalyst = Set<Catalyst>()

    func save(input: ReactionInput, order: ReactionOrder, reaction: OrderedReactionSet) {
        let key = ReactionInputKey(order: order, type: reaction)
        underlying[key] = input
    }

    func get(order: ReactionOrder, reaction: OrderedReactionSet) -> ReactionInput? {
        let key = ReactionInputKey(order: order, type: reaction)
        return underlying[key]
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

    fileprivate struct ReactionInputKey: Hashable {
        let order: ReactionOrder
        let type: OrderedReactionSet
    }

}
