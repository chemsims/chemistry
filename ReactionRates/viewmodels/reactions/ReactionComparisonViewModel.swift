//
// Reactions App
//

import SwiftUI
import ReactionsCore

class ReactionComparisonViewModel: ObservableObject {

    let persistence: ReactionInputPersistence
    init(persistence: ReactionInputPersistence) {
        self.persistence = persistence
        self.zeroOrderInput = persistence.get(order: .Zero, reaction: .A) ?? ReactionComparisonDefaults.input
        self.firstOrderInput = persistence.get(order: .First, reaction: .A) ?? ReactionComparisonDefaults.input
        self.secondOrderInput = persistence.get(order: .Second, reaction: .A) ?? ReactionComparisonDefaults.input
    }

    private let zeroOrderInput: ReactionInput
    private let firstOrderInput: ReactionInput
    private let secondOrderInput: ReactionInput

    var navigation: NavigationModel<ReactionComparisonState>?

    @Published var statement = [TextLine]()
    @Published var currentTime0: CGFloat?
    @Published var currentTime1: CGFloat?
    @Published var currentTime2: CGFloat?
    @Published var highlightedElements = [ReactionComparisonScreenElement]()
    @Published var canDragOrders = false
    @Published var correctOrderSelections = [ReactionOrder]()
    @Published var reactionHasEnded = false
    @Published var canStartAnimation = false

    @Published var showDragTutorial = false
    @Published var dragTutorialHandIsMoving = false
    @Published var dragTutorialHandIsComplete = false

    let reactionOrdering: [ReactionOrder] = [.Zero, .First, .Second].shuffled()

    let initialTime: CGFloat = 0

    let moleculesA = MoleculeGridSettings.fullGrid.shuffled()

    func addToCorrectSelection(order: ReactionOrder) {
        correctOrderSelections.append(order)
    }

    func next() {
        if !canClickNext {
            statement = ReactionComparisonStatements.blockClickingNextBeforeChoosingReactions
        } else {
            navigation?.next()
            if reactionHasEnded {
                persistence.setHasIdentifiedReactionOrders()
            }
        }
    }

    var canClickNext: Bool {
        let reactionIsRunning = currentTime0 != nil && reactionHasEnded == false
        let hasIdentifiedOrders = persistence.hasIdentifiedReactionOrders()
        let ordersHaveBeenSelected = correctOrderSelections.count == ReactionOrder.allCases.count
        let nextIsBlocked = reactionIsRunning && !hasIdentifiedOrders && !ordersHaveBeenSelected
        return !nextIsBlocked
    }

    func back() {
        navigation?.back()
    }

    var finalTime0: CGFloat {
        zeroOrder.time(for: 0.1)!
    }

    var finalTime1: CGFloat {
        firstOrder.time(for: 0.1)!
    }

    var finalTime2: CGFloat {
        secondOrder.time(for: 0.1)!
    }

    var zeroOrder: ZeroOrderConcentration {
        let k = ZeroOrderConcentration.getRate(
            t1: zeroOrderInput.t1,
            c1: zeroOrderInput.c1,
            t2: zeroOrderInput.t2,
            c2: zeroOrderInput.c2
        )
        return ZeroOrderConcentration(a0: 1, rateConstant: k)
    }

    var firstOrder: FirstOrderConcentration {
        let k = FirstOrderConcentration.rateConstant(
            c1: firstOrderInput.c1,
            c2: firstOrderInput.c2,
            t1: firstOrderInput.t1,
            t2: firstOrderInput.t2
        )
        return FirstOrderConcentration(a0: 1, rateConstant: k)
    }

    var secondOrder: SecondOrderConcentration {
        let k = SecondOrderConcentration.rateConstant(
            c1: secondOrderInput.c1,
            c2: secondOrderInput.c2,
            t1: secondOrderInput.t1,
            t2: secondOrderInput.t2
        )
        return SecondOrderConcentration(a0: 1, rateConstant: k)
    }

    var zeroOrderB: Equation {
        concentrationB(concentrationA: zeroOrder)
    }

    var firstOrderB: Equation {
        concentrationB(concentrationA: firstOrder)
    }

    var secondOrderB: Equation {
        concentrationB(concentrationA: secondOrder)
    }

    private func concentrationB(
        concentrationA: ConcentrationEquation
    ) -> Equation {
        ConcentrationBEquation(concentrationA: concentrationA, initialAConcentration: 1)
    }

}

struct ReactionComparisonDefaults {
    static let c1: CGFloat = 1
    static let c2: CGFloat = 0.1
    static let time: CGFloat = 15

    static var input: ReactionInput {
        ReactionInput(
            c1: c1,
            c2: c2,
            t1: 0,
            t2: time
        )
    }
}
