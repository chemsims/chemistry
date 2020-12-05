//
// Reactions App
//
  

import SwiftUI

class NewReactionComparisonViewModel: ObservableObject {

    @Published var currentTime: CGFloat?
    @Published var highlightedElements = [ReactionComparisonScreenElement]()

    let initialTime: CGFloat = 0
    let finalTime: CGFloat = 15

    let moleculesA = MoleculeGridSettings.fullGrid.shuffled()

    var zeroOrder: ConcentrationEquation {
        LinearConcentration(
            a0: 1,
            rate: 0.05
        )
    }

    var firstOrder: ConcentrationEquation {
        FirstOrderConcentration(
            initialConcentration: 1,
            rate: 0.2
        )
    }

    var secondOrder: ConcentrationEquation {
        SecondOrderConcentration(
            initialConcentration: 1,
            rate: 0.2
        )
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
