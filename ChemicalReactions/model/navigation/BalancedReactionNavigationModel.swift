//
// Reactions App
//

import Foundation
import ReactionsCore

private let statements = ChemicalReactionStatements.self

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
    ]
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
    }

    override func unapply(on model: BalancedReactionScreenViewModel) {
        model.showDragTutorial = false
    }
}
