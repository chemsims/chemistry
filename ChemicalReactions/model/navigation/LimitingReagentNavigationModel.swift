//
// Reactions App
//

import ReactionsCore

private let statements = LimitingReagentStatements.self

struct LimitingReagentNavigationModel {
    private init() { }

    static func model(using viewModel: LimitingReagentScreenViewModel) -> NavigationModel<LimitingReagentScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states: [LimitingReagentScreenState] = [
        SetStatement(statements.intro)
    ]
}

class LimitingReagentScreenState: ScreenState, SubState {

    typealias Model = LimitingReagentScreenViewModel
    typealias NestedState = LimitingReagentScreenState


    func apply(on model: LimitingReagentScreenViewModel) {
    }

    func reapply(on model: LimitingReagentScreenViewModel) {
        apply(on: model)
    }

    func unapply(on model: LimitingReagentScreenViewModel) {
    }

    func delayedStates(model: LimitingReagentScreenViewModel) -> [DelayedState<LimitingReagentScreenState>] {
        []
    }

    func nextStateAutoDispatchDelay(model: LimitingReagentScreenViewModel) -> Double? {
        nil
    }
}

private class SetStatement: LimitingReagentScreenState {
    init(_ statement: [TextLine]) {
        self.statement = statement
    }

    let statement: [TextLine]

    override func apply(on model: LimitingReagentScreenViewModel) {
        model.statement = statement
    }
}
