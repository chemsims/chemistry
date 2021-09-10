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
        SetStatement(statements.intro),
        SetStatement(statements.explainEmpiricalFormula),
        SetStatement(statements.empiricalFormulaExample),
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
}

private class SetStatement: BalancedReactionScreenState {

    init(_ statement: [TextLine]) {
        self.statement = statement
    }

    let statement: [TextLine]

    override func apply(on model: BalancedReactionScreenViewModel) {
        model.statement = statement
    }
}

private class ShowDraggingTutorial: SetStatement {

    override func apply(on model: BalancedReactionScreenViewModel) {
        super.apply(on: model)
        model.showDragTutorial = true
        model.inputState = .dragMolecules
    }

    override func reapply(on model: BalancedReactionScreenViewModel) {
        super.apply(on: model)
        model.inputState = .dragMolecules
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
    }
}

private class DragMolecules: BalancedReactionScreenState {
    override func apply(on model: BalancedReactionScreenViewModel) {
        model.statement = statements.instructToDragMoleculesForSubsequentReaction
        model.inputState = .dragMolecules
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
    }
}
