//
// Reactions App
//

import Foundation

protocol PrecipitationInputPersistence {
    var beakerView: PrecipitationScreenViewModel.BeakerView? { get }
    func setBeakerView(_ value: PrecipitationScreenViewModel.BeakerView) -> Void

    func setComponentInput(reactionIndex index: Int, input: PrecipitationComponents.Input) -> Void
    func getComponentInput(reactionIndex index: Int) -> PrecipitationComponents.Input?

    var lastChosenReactionIndex: Int? { get }
    var lastChosenReactionMetal: PrecipitationReaction.Metal? { get }

    func setLastChosenReactionIndex(_ value: Int) -> Void
    func setLastChosenReactionMetal(_ value: PrecipitationReaction.Metal) -> Void
}

class InMemoryPrecipitationInputPersistence: PrecipitationInputPersistence {

    var beakerView: PrecipitationScreenViewModel.BeakerView? = nil

    private var inputMap = [Int : PrecipitationComponents.Input]()
    private(set) var lastChosenReactionIndex: Int?
    var lastChosenReactionMetal: PrecipitationReaction.Metal?

    func setComponentInput(reactionIndex index: Int, input: PrecipitationComponents.Input) {
        inputMap[index] = input
    }

    func getComponentInput(reactionIndex index: Int) -> PrecipitationComponents.Input? {
        inputMap[index]
    }

    func setBeakerView(_ value: PrecipitationScreenViewModel.BeakerView) {
        beakerView = value
    }

    func setLastChosenReactionIndex(_ value: Int) {
        lastChosenReactionIndex = value
    }

    func setLastChosenReactionMetal(_ value: PrecipitationReaction.Metal) {
        lastChosenReactionMetal = value
    }
}

class UserDefaultsPrecipitationInputPersistence: PrecipitationInputPersistence {

    init(prefix: String) {
        self.prefix = prefix
    }

    let prefix: String
    private let userDefaults = UserDefaults.standard

    var beakerView: PrecipitationScreenViewModel.BeakerView? {
        if let data = userDefaults.data(forKey: beakerKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode(PrecipitationScreenViewModel.BeakerView.self, from: data)
        }
        return nil
    }

    var lastChosenReactionIndex: Int? {
        if userDefaults.object(forKey: lastReactionIndexKey) == nil {
            return nil
        }
        return userDefaults.integer(forKey: lastReactionIndexKey)
    }

    var lastChosenReactionMetal: PrecipitationReaction.Metal? {
        let decoder = JSONDecoder()
        if let data = userDefaults.data(forKey: lastMetalKey) {
            return try? decoder.decode(PrecipitationReaction.Metal.self, from: data)
        }
        return nil
    }

    func getComponentInput(reactionIndex index: Int) -> PrecipitationComponents.Input? {
        let key = reactionKey(index: index)
        let decoder = JSONDecoder()
        if let data = userDefaults.data(forKey: key) {
            return try? decoder.decode(PrecipitationComponents.Input.self, from: data)
        }
        return nil
    }

    func setComponentInput(reactionIndex index: Int, input: PrecipitationComponents.Input) {
        let key = reactionKey(index: index)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(input) {
            userDefaults.set(data, forKey: key)
        }
    }

    func setBeakerView(_ value: PrecipitationScreenViewModel.BeakerView) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            userDefaults.set(data, forKey: beakerKey)
        }
    }

    func setLastChosenReactionIndex(_ value: Int) {
        userDefaults.set(value, forKey: lastReactionIndexKey)
    }

    func setLastChosenReactionMetal(_ value: PrecipitationReaction.Metal) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            userDefaults.set(data, forKey: lastMetalKey)
        }
    }

    private var beakerKey: String {
        "\(prefix).precipitation.beakerView"
    }

    private func reactionKey(index: Int) -> String {
        "\(prefix).precipitation.reaction.\(index)"
    }

    private var lastReactionIndexKey: String {
        "\(prefix).precipitation.lastReaction.index"
    }

    private var lastMetalKey: String {
        "\(prefix).precipitation.lastReaction.metal"
    }
}

private struct SavedReaction: Codable {
    let id: String
    let metal: String
}

extension SavedReaction {
    init(reaction: PrecipitationReaction) {
        self.init(id: reaction.id, metal: reaction.unknownReactant.metal.rawValue)
    }
}
