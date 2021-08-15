//
// Reactions App
//

import Foundation
import ReactionsCore

protocol ReactionInputPersistence {

    func save(input: ReactionInput, order: ReactionOrder, reaction: ReactionType)
    func get(order: ReactionOrder, reaction: ReactionType) -> ReactionInput?

    func setCompleted(screen: ReactionRatesScreen)
    func hasCompleted(screen: ReactionRatesScreen) -> Bool

    func hasIdentifiedReactionOrders() -> Bool
    func setHasIdentifiedReactionOrders()
}

extension ReactionInputPersistence {
    var hasCompletedApp: Bool {
        hasCompleted(screen: .energyProfileQuiz)
    }
}

class UserDefaultsReactionInputPersistence: ReactionInputPersistence {

    private let defaults = UserDefaults.standard

    func save(input: ReactionInput, order: ReactionOrder, reaction: ReactionType) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(input) {
            defaults.set(encoded, forKey: inputKey(order: order, type: reaction))
        }
    }

    func get(order: ReactionOrder, reaction: ReactionType) -> ReactionInput? {
        let decoder = JSONDecoder()
        if let data = defaults.data(forKey: inputKey(order: order, type: reaction)) {
            return try? decoder.decode(ReactionInput.self, from: data)
        }
        return nil
    }

    func setCompleted(screen: ReactionRatesScreen) {
        defaults.set(true, forKey: screenKey(screen))
    }

    func hasCompleted(screen: ReactionRatesScreen) -> Bool {
        defaults.bool(forKey: screenKey(screen))
    }

    func hasIdentifiedReactionOrders() -> Bool {
        defaults.bool(forKey: identifiedOrdersKey)
    }

    func setHasIdentifiedReactionOrders() {
        defaults.set(true, forKey: identifiedOrdersKey)
    }

    private func inputKey(order: ReactionOrder, type: ReactionType) -> String {
        "\(order.rawValue)-\(type.rawValue)"
    }

    private func screenKey(_ screen: ReactionRatesScreen) -> String {
        "completed-screen-\(screen.rawValue)"
    }

    private let identifiedOrdersKey = "identified-reaction-orders"

}

class InMemoryReactionInputPersistence: ReactionInputPersistence {

    private var underlying = [ReactionInputKey: ReactionInput]()

    private var underlyingScreenCompletions = Set<ReactionRatesScreen>()

    private var _hasIdentifiedReactionOrders = false

    func save(input: ReactionInput, order: ReactionOrder, reaction: ReactionType) {
        let key = ReactionInputKey(order: order, type: reaction)
        underlying[key] = input
    }

    func get(order: ReactionOrder, reaction: ReactionType) -> ReactionInput? {
        let key = ReactionInputKey(order: order, type: reaction)
        return underlying[key]
    }

    func setCompleted(screen: ReactionRatesScreen) {
        underlyingScreenCompletions.insert(screen)
    }

    func hasCompleted(screen: ReactionRatesScreen) -> Bool {
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
