//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationPhase2Components: ObservableObject {

    init(
        previous: TitrationComponents
    ) {
        self.previous = previous
        self.initialSubstanceMolarity = previous.volume * previous.concentration.substance.getY(at: 1)
    }

    let initialSubstanceMolarity: CGFloat
    let previous: TitrationComponents

    @Published var kohMolarity: CGFloat = 0.02

    var epConcentration: SubstanceValue<Equation> {
        AcidConcentrationEquations.concentrations(
            forPartsOf: previous.substance,
            initialSubstanceConcentration: finalSecondaryConcentration
        )
    }

    private var volumeKohToAdd: CGFloat {
        initialSubstanceMolarity / kohMolarity
    }

    private var finalSecondaryConcentration: CGFloat {
        initialSubstanceMolarity / (previous.volume + volumeKohToAdd)
    }
}
