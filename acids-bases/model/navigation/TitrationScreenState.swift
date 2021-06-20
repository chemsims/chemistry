//
// Reactions App
//


import ReactionsCore

private let statements = TitrationStatements.self

struct TitrationNavigationModel {
    private init() { }

    static func model(_ viewModel: TitrationViewModel) -> NavigationModel<TitrationScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states: [TitrationScreenState] = [
        SetStatement(statements.intro)
    ]
}

class TitrationScreenState: ScreenState, SubState {
    typealias Model = TitrationViewModel
    typealias NestedState = TitrationScreenState

    func apply(on model: TitrationViewModel) {
    }

    func reapply(on model: TitrationViewModel) {
        apply(on: model)
    }

    func unapply(on model: TitrationViewModel) {
    }

    func delayedStates(model: TitrationViewModel) -> [DelayedState<TitrationScreenState>] {
        []
    }

    func nextStateAutoDispatchDelay(model: TitrationViewModel) -> Double? {
        nil
    }
}

private class SetStatement: TitrationScreenState {
    init(_ statement: [TextLine]) {
        self.getStatement = { _ in statement }
    }

    private let getStatement: (TitrationViewModel) -> [TextLine]

    override func apply(on model: TitrationViewModel) {
        model.statement = getStatement(model)
    }
}
