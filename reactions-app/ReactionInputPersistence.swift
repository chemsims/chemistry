//
// Reactions App
//
  

import Foundation

protocol ReactionInputPersistence {

    func save(input: ReactionInput, order: ReactionOrder)
    func get(order: ReactionOrder) -> ReactionInput?

}

class InMemoryReactionInputPersistence: ReactionInputPersistence {

    private var underlying = [ReactionOrder:ReactionInput]()

    func save(input: ReactionInput, order: ReactionOrder) {
        underlying[order] = input
    }

    func get(order: ReactionOrder) -> ReactionInput? {
        underlying[order]
    }


}
