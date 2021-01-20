//
// Reactions App
//
  

import Foundation

struct EnergyProfileInput {
    let catalysts: [Catalyst]
    let order: ReactionOrder
}

protocol EnergyProfilePersistence {

    func setInput(_ input: EnergyProfileInput)
    func getInput() -> EnergyProfileInput?
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
