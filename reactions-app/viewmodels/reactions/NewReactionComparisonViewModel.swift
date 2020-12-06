//
// Reactions App
//
  

import SwiftUI

class NewReactionComparisonViewModel: ObservableObject {

    let persistence: ReactionInputPersistence
    init(persistence: ReactionInputPersistence) {
        self.persistence = persistence
        self.zeroOrderInput = persistence.get(order: .Zero) ?? ReactionComparisonDefaults.input
        self.firstOrderInput = persistence.get(order: .First) ?? ReactionComparisonDefaults.input
        self.secondOrderInput = persistence.get(order: .Second) ?? ReactionComparisonDefaults.input
    }

    private let zeroOrderInput: ReactionInput
    private let firstOrderInput: ReactionInput
    private let secondOrderInput: ReactionInput

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
        let eq = LinearConcentration(
            t1: zeroOrderInput.t1,
            c1: zeroOrderInput.c1,
            t2: zeroOrderInput.t2,
            c2: zeroOrderInput.c2
        )
        return LinearConcentration(a0: 1, rate: eq.rate)
    }

    var firstOrder: FirstOrderConcentration {
        let rate = FirstOrderConcentration.getRate(
            c1: firstOrderInput.c1,
            c2: firstOrderInput.c2,
            time: firstOrderInput.t2 - firstOrderInput.t1
        )
        return FirstOrderConcentration(initialConcentration: 1, rate: rate)
    }

    var secondOrder: SecondOrderConcentration {
        let rate = SecondOrderConcentration.getRate(
            c1: secondOrderInput.c1,
            c2: secondOrderInput.c2,
            time: secondOrderInput.t2 - secondOrderInput.t1
        )
        return SecondOrderConcentration(initialConcentration: 1, rate: rate)
    }

    var zeroOrderRate: Equation {
        RateEquation(k: zeroOrder.rate, concentration: zeroOrder)
    }

    var firstOrderRate: Equation {
        RateEquation(k: firstOrder.rate, concentration: firstOrder)
    }

    var secondOrderRate: Equation {
        RateEquation(k: secondOrder.rate, concentration: secondOrder)
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

struct RateEquation: Equation {
    let k: CGFloat
    let concentration: ConcentrationEquation

    func getY(at x: CGFloat) -> CGFloat {
        k * concentration.getConcentration(at: x)
    }

}
