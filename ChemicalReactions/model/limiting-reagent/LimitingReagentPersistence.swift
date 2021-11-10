//
// Reactions App
//

import Foundation

protocol LimitingReagentPersistence {

    var input: LimitingReagentComponents.ReactionInput? { get }

    func saveInput(_ input: LimitingReagentComponents.ReactionInput) -> Void
}

class InMemoryLimitingReagentPersistence: LimitingReagentPersistence {
    var input: LimitingReagentComponents.ReactionInput? = nil

    func saveInput(_ input: LimitingReagentComponents.ReactionInput) {
        self.input = input
    }
}

class UserDefaultsLimitingReagentPersistence: LimitingReagentPersistence {
    init(prefix: String) {
        self.prefix = prefix
    }

    let prefix: String
    private let userDefaults = UserDefaults.standard

    private var key: String {
        "\(prefix).limitingReagentReaction"
    }

    var input: LimitingReagentComponents.ReactionInput? {
        let decoder = JSONDecoder()
        if let data = userDefaults.data(forKey: key) {
            return try? decoder.decode(LimitingReagentComponents.ReactionInput.self, from: data)
        }
        return nil
    }

    func saveInput(_ input: LimitingReagentComponents.ReactionInput) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(input) {
            userDefaults.set(data, forKey: key)
        }
    }
}
