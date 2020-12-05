//
// Reactions App
//
  

import SwiftUI

class NewReactionComparisonViewModel: ObservableObject {


    @Published var currentTime: CGFloat?

    let moleculesA = MoleculeGridSettings.fullGrid

    var zeroOrder: ConcentrationEquation {
        ConstantConcentration(value: 0.5)
    }

    var firstOrder: ConcentrationEquation {
        ConstantConcentration(value: 0.5)
    }

    var secondOrder: ConcentrationEquation {
        ConstantConcentration(value: 0.5)
    }

    var zeroOrderB: ConcentrationEquation {
        ConstantConcentration(value: 0.25)
    }

    var firstOrderB: ConcentrationEquation {
        ConstantConcentration(value: 0.25)
    }

    var secondOrderB: ConcentrationEquation {
        ConstantConcentration(value: 0.25)
    }

}
