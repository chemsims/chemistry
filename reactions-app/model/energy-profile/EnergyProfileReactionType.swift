//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileReactionInput {
    let moleculeA: EnergyProfileMoleculeSettings
    let moleculeB: EnergyProfileMoleculeSettings
    let moleculeC: EnergyProfileMoleculeSettings
}



extension ReactionOrder {

    var energyProfileReactionInput: EnergyProfileReactionInput {
        switch (self) {
        case .Zero: return zeroOrderInput
        case .First: return firstOrderInput
        case .Second: return secondOrderInput
        }
    }

    private var zeroOrderInput: EnergyProfileReactionInput {
        EnergyProfileReactionInput(
            moleculeA: EnergyProfileMoleculeSettings(
                name: "A",
                color: .moleculeA
            ),
            moleculeB: EnergyProfileMoleculeSettings(
                name: "B",
                color: .moleculeB
            ),
            moleculeC: EnergyProfileMoleculeSettings(
                name: "C",
                color: .moleculeC
            )
        )
    }

    private var firstOrderInput: EnergyProfileReactionInput {
        EnergyProfileReactionInput(
            moleculeA: EnergyProfileMoleculeSettings(
                name: "D",
                color: .moleculeD
            ),
            moleculeB: EnergyProfileMoleculeSettings(
                name: "E",
                color: .moleculeE
            ),
            moleculeC: EnergyProfileMoleculeSettings(
                name: "F",
                color: .moleculeF
            )
        )
    }

    private var secondOrderInput: EnergyProfileReactionInput {
        EnergyProfileReactionInput(
            moleculeA: EnergyProfileMoleculeSettings(
                name: "G",
                color: .moleculeG
            ),
            moleculeB: EnergyProfileMoleculeSettings(
                name: "H",
                color: .moleculeH
            ),
            moleculeC: EnergyProfileMoleculeSettings(
                name: "I",
                color: .moleculeI
            )
        )
    }
}

struct EnergyProfileMoleculeSettings {
    let name: String
    let color: RGB
}
