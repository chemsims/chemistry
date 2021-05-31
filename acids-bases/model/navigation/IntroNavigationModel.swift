//
// Reactions App
//

import ReactionsCore

private let statements = IntroStatements.self

struct IntroNavigationModel {

    static func model(
        _ viewModel: IntroScreenViewModel
    ) -> NavigationModel<IntroScreenState> {
        NavigationModel(
            model: viewModel,
            states: states
        )
    }

    private static let states: [IntroScreenState] = [
        SetStatement(statements.intro),
        SetStatement(statements.explainTexture),
        SetStatement(statements.explainArrhenius),
        SetStatement(statements.explainBronstedLowry),
        SetStatement(statements.explainLewis),
        SetStatement(statements.explainSimpleDefinition),
        SetStatement(statements.chooseStrongAcid)
    ]

}

class IntroScreenState: ScreenState, SubState {

    typealias NestedState = IntroScreenState
    typealias Model = IntroScreenViewModel

    func apply(on model: IntroScreenViewModel) {
    }

    func reapply(on model: IntroScreenViewModel) {
        apply(on: model)
    }

    func delayedStates(model: IntroScreenViewModel) -> [DelayedState<IntroScreenState>] {
        []
    }

    func unapply(on model: IntroScreenViewModel) {
    }

    func nextStateAutoDispatchDelay(model: IntroScreenViewModel) -> Double? {
        nil
    }
}

private class SetStatement: IntroScreenState {

    let statement: [TextLine]
    init(_ statement: [TextLine]) {
        self.statement = statement
    }

    override func apply(on model: IntroScreenViewModel) {
        model.statement = statement
    }
}
