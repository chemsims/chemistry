//
// Reactions App
//

import Foundation

protocol PrecipitationInputPersistence {
    var input: PrecipitationComponents.Input? { get }
    var beakerView: PrecipitationScreenViewModel.BeakerView? { get }
    var reaction: PrecipitationReaction? { get }

    func setComponentInput(_ value: PrecipitationComponents.Input) -> Void
    func setBeakerView(_ value: PrecipitationScreenViewModel.BeakerView) -> Void
    func setReaction(_ value: PrecipitationReaction) -> Void
}

class InMemoryPrecipitationInputPersistence: PrecipitationInputPersistence {

    var input: PrecipitationComponents.Input? = nil
    var beakerView: PrecipitationScreenViewModel.BeakerView? = nil
    var reaction: PrecipitationReaction? = nil

    func setComponentInput(_ value: PrecipitationComponents.Input) {
        input = value
    }

    func setBeakerView(_ value: PrecipitationScreenViewModel.BeakerView) {
        beakerView = value
    }

    func setReaction(_ value: PrecipitationReaction) {
        reaction = value
    }
}

class UserDefaultsPrecipitationInputPersistence: PrecipitationInputPersistence {

    init(prefix: String) {
        self.prefix = prefix
    }

    let prefix: String
    private let userDefaults = UserDefaults.standard

    var input: PrecipitationComponents.Input? {
        if let data = userDefaults.data(forKey: inputKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode(PrecipitationComponents.Input.self, from: data)
        }
        return nil
    }

    var beakerView: PrecipitationScreenViewModel.BeakerView? {
        if let data = userDefaults.data(forKey: beakerKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode(PrecipitationScreenViewModel.BeakerView.self, from: data)
        }
        return nil
    }

    var reaction: PrecipitationReaction? {
        let decoder = JSONDecoder()
        if let data = userDefaults.data(forKey: reactionKey),
           let model = try? decoder.decode(SavedReaction.self, from: data),
           let metal = PrecipitationReaction.Metal(rawValue: model.metal) {
            return PrecipitationReaction.fromId(model.id, metal: metal)
        }
        return nil
    }

    func setComponentInput(_ value: PrecipitationComponents.Input) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            userDefaults.set(data, forKey: inputKey)
        }
    }

    func setBeakerView(_ value: PrecipitationScreenViewModel.BeakerView) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            userDefaults.set(data, forKey: beakerKey)
        }
    }

    func setReaction(_ value: PrecipitationReaction) {
        let model = SavedReaction(reaction: value)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            userDefaults.set(data, forKey: reactionKey)
        }
    }


    private var inputKey: String {
        "\(prefix).precipitation.input"
    }

    private var beakerKey: String {
        "\(prefix).precipitation.beakerView"
    }

    private var reactionKey: String {
        "\(prefix).precipitation.reaction"
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
