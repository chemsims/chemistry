//
// Reactions App
//
  

import SwiftUI

class NewReactionComparisonViewModel: ObservableObject {

    @Published var currentTime: CGFloat?
    @Published var highlightedElements = [ReactionComparisonScreenElement]()
    @Published var canDragOrders = false
    @Published var correctOrderSelections = [ReactionOrder]()

    let initialTime: CGFloat = 0

    let moleculesA = MoleculeGridSettings.fullGrid.shuffled()

    func addToCorrectSelection(order: ReactionOrder) {
        correctOrderSelections.append(order)
    }

    var finalTime: CGFloat {
        let minConcentration: CGFloat = 0.05
        let zeroOrderTime = zeroOrder.time(for: minConcentration)!
        let firstOrderTime = firstOrder.time(for: minConcentration)!
        let secondOrderTime = secondOrder.time(for: minConcentration)!
        return [zeroOrderTime, firstOrderTime, secondOrderTime].max()!
    }

    var zeroOrder: LinearConcentration {
        LinearConcentration(
            a0: 1,
            rate: 0.05
        )
    }

    var firstOrder: FirstOrderConcentration {
        FirstOrderConcentration(
            initialConcentration: 1,
            rate: 0.2
        )
    }

    var secondOrder: SecondOrderConcentration {
        SecondOrderConcentration(
            initialConcentration: 1,
            rate: 0.7
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
