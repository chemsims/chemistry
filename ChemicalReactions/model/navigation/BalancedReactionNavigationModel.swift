//
// Reactions App
//

import Foundation
import ReactionsCore

private let statements = BalancedReactionStatements.self

struct BalancedReactionNavigationModel {
    private init() { }

    static func model(using viewModel: BalancedReactionScreenViewModel) -> NavigationModel<BalancedReactionScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states: [BalancedReactionScreenState] = [
        ChooseInitialReaction(statements.intro),
        PostChooseInitialReaction(statements.explainEmpiricalFormula),
        SetStatement { statements.empiricalFormulaExample(reaction: $0.reaction) },
        SetStatement(statements.explainStoichiometricCoeffs),
        SetStatement(statements.explainBalancedReaction),
        ShowDraggingTutorial(statements.instructToDragMoleculeForFirstReaction)
    ] + balanceRemainingReactionStates + [FinalState()]

    private static let balanceRemainingReactionStates =
        (0..<(BalancedReaction.availableReactions.count - 1)).flatMap { _ in
            [
                ChooseNewReactionPostBalancing(),
                DragMolecules()
            ]
        }
}

class BalancedReactionScreenState: ScreenState, SubState {

    typealias Model = BalancedReactionScreenViewModel
    typealias NestedState = BalancedReactionScreenState

    func apply(on model: BalancedReactionScreenViewModel) {
    }

    func reapply(on model: BalancedReactionScreenViewModel) {
        apply(on: model)
    }

    func unapply(on model: BalancedReactionScreenViewModel) {
    }

    func delayedStates(model: BalancedReactionScreenViewModel) -> [DelayedState<BalancedReactionScreenState>] {
        []
    }

    func nextStateAutoDispatchDelay(model: BalancedReactionScreenViewModel) -> Double? {
        nil
    }
    
    var backBehaviour: NavigationModelBackBehaviour {
        .unapply
    }
}

private class SetStatement: BalancedReactionScreenState {

    init(_ statement: [TextLine]) {
        self.statement = { _ in statement }
    }

    init(_ statement: @escaping (BalancedReactionScreenViewModel) -> [TextLine]) {
        self.statement = statement
    }

    private let statement: (BalancedReactionScreenViewModel) -> [TextLine]

    override func apply(on model: BalancedReactionScreenViewModel) {
        model.statement = statement(model)
    }
}

private class ChooseInitialReaction: SetStatement {
    override func apply(on model: BalancedReactionScreenViewModel) {
        super.apply(on: model)
        model.inputState = .selectReaction
        model.hasSelectedFirstReaction = false
    }
}

private class PostChooseInitialReaction: SetStatement {
    override func apply(on model: BalancedReactionScreenViewModel) {
        super.apply(on: model)
        model.inputState = nil
    }

    override func unapply(on model: BalancedReactionScreenViewModel) {
        model.restorePreviousMolecules()
    }
}

private class ShowDraggingTutorial: SetStatement {

    override func apply(on model: BalancedReactionScreenViewModel) {
        super.apply(on: model)
        model.showDragTutorial = true
        model.inputState = .dragMolecules
        model.resetMolecules()
    }

    override func reapply(on model: BalancedReactionScreenViewModel) {
        super.apply(on: model)
        model.inputState = .dragMolecules
        model.resetMolecules()
    }

    override func unapply(on model: BalancedReactionScreenViewModel) {
        model.showDragTutorial = false
        model.resetMolecules()
        model.inputState = nil
    }
}

private class ChooseNewReactionPostBalancing: BalancedReactionScreenState {
    override func apply(on model: BalancedReactionScreenViewModel) {
        model.statement = statements.instructToChooseReactionPostBalancing
        model.inputState = .selectReaction
        model.emphasiseReactionCoefficients = false
    }

    override func unapply(on model: BalancedReactionScreenViewModel) {
        model.emphasiseReactionCoefficients = true
    }
}

private class DragMolecules: BalancedReactionScreenState {
    override func apply(on model: BalancedReactionScreenViewModel) {
        model.statement = statements.instructToDragMoleculesForSubsequentReaction
        model.inputState = .dragMolecules
        model.emphasiseReactionCoefficients = true
        model.moleculesInFlight.removeAll()
        model.moleculesInFlightOverProduct.removeAll()
        model.moleculesInFlightOverReactant.removeAll()
    }

    override func unapply(on model: BalancedReactionScreenViewModel) {
        model.inputState = nil
        model.restorePreviousMolecules()
    }
}

private class FinalState: BalancedReactionScreenState {
    override func apply(on model: BalancedReactionScreenViewModel) {
        model.statement = statements.finalStatement
        model.inputState = nil
        model.emphasiseReactionCoefficients = false
    }

    override func unapply(on model: BalancedReactionScreenViewModel) {
        model.emphasiseReactionCoefficients = true
    }
}
