//
// Reactions App
//
  

import SwiftUI

class NewReactionComparisonViewModel: ObservableObject {

    @Published var currentTime: CGFloat?

    let initialTime: CGFloat = 0
    let finalTime: CGFloat = 15

    let moleculesA = MoleculeGridSettings.fullGrid.shuffled()

    var zeroOrder: ConcentrationEquation {
        LinearConcentration(t1: initialTime, c1: 1, t2: finalTime, c2: 0.1)
    }

    var firstOrder: ConcentrationEquation {
        FirstOrderConcentration(c1: 1, c2: 0.1, time: finalTime)
    }

    var secondOrder: ConcentrationEquation {
        SecondOrderConcentration(c1: 1, c2: 0.1, time: finalTime)
    }

    var zeroOrderB: ConcentrationEquation {
        concentrationB(concentrationA: zeroOrder)
    }

    var firstOrderB: ConcentrationEquation {
        concentrationB(concentrationA: firstOrder)
    }

    var secondOrderB: ConcentrationEquation {
        concentrationB(concentrationA: secondOrder)
    }

    private func concentrationB(
        concentrationA: ConcentrationEquation
    ) -> ConcentrationEquation {
        ConcentrationBEquation(concentrationA: concentrationA, initialAConcentration: 1)
    }

}
