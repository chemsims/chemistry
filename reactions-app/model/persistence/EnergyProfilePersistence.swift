//
// Reactions App
//
  

import Foundation

struct EnergyProfileInput: Equatable, Codable {
    let catalysts: [Catalyst]
    let order: ReactionOrder
}

protocol EnergyProfilePersistence {

    func setInput(_ input: EnergyProfileInput)
    func getInput() -> EnergyProfileInput?
}

class UserDefaultsEnergyProfilePersistence: EnergyProfilePersistence {

    private let defaults = UserDefaults.standard

    func setInput(_ input: EnergyProfileInput) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(input) {
            defaults.set(data, forKey: key)
        }
    }

    func getInput() -> EnergyProfileInput? {
        if let data = defaults.data(forKey: key) {
            let decoder = JSONDecoder()
            return try? decoder.decode(EnergyProfileInput.self, from: data)
        }
        return nil
    }

    private let key = "energy-profile-input"
}

class InMemoryEnergyProfilePersistence: EnergyProfilePersistence {

    private var underlying: EnergyProfileInput?

    func setInput(_ input: EnergyProfileInput) {
        underlying = input
    }

    func getInput() -> EnergyProfileInput? {
        underlying
    }
}
