//
// Reactions App
//

import Foundation

protocol LimitingReagentPersistence {

    func getInput(reaction: LimitingReagentReaction) -> LimitingReagentComponents.ReactionInput?

    func saveInput(reaction: LimitingReagentReaction, _ input: LimitingReagentComponents.ReactionInput) -> Void

}

class InMemoryLimitingReagentPersistence: LimitingReagentPersistence {

    private var underlyingMap = [String : LimitingReagentComponents.ReactionInput]()

    func getInput(reaction: LimitingReagentReaction) -> LimitingReagentComponents.ReactionInput? {
        underlyingMap[reaction.id]
    }

    func saveInput(reaction: LimitingReagentReaction, _ input: LimitingReagentComponents.ReactionInput) {
        underlyingMap[reaction.id] = input
    }

}

class UserDefaultsLimitingReagentPersistence: LimitingReagentPersistence {
    init(prefix: String) {
        self.prefix = prefix
    }

    let prefix: String
    private let userDefaults = UserDefaults.standard

    func saveInput(reaction: LimitingReagentReaction, _ input: LimitingReagentComponents.ReactionInput) {
        let encoder = JSONEncoder()
        let key = reactionKey(reaction)
        if let data = try? encoder.encode(input) {
            userDefaults.set(data, forKey: key)
        }
    }

    func getInput(reaction: LimitingReagentReaction) -> LimitingReagentComponents.ReactionInput? {
        let key = reactionKey(reaction)
        let decoder = JSONDecoder()
        if let data = userDefaults.data(forKey: key) {
            return try? decoder.decode(LimitingReagentComponents.ReactionInput.self, from: data)
        }
        return nil
    }

    private func reactionKey(_ reaction: LimitingReagentReaction) -> String {
        "\(prefix).limitingReagentReaction.\(reaction.id)"
    }
}
