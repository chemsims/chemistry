//
// Reactions App
//


import Foundation
import ReactionsCore

private let statements = PrecipitationStatements.self

struct PrecipitationNavigationModel {
    private init() { }

    static func model(using viewModel: PrecipitationScreenViewModel) -> NavigationModel<PrecipitationScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states: [PrecipitationScreenState] = [
        SetStatement(statements.intro)
    ]
}

class PrecipitationScreenState: ScreenState, SubState {
    typealias Model = PrecipitationScreenViewModel
    typealias NestedState = PrecipitationScreenState

    func apply(on model: PrecipitationScreenViewModel) {
    }

    func reapply(on model: PrecipitationScreenViewModel) {
        apply(on: model)
    }

    func unapply(on model: PrecipitationScreenViewModel) {
    }

    func delayedStates(model: PrecipitationScreenViewModel) -> [DelayedState<PrecipitationScreenState>] {
        []
    }

    func nextStateAutoDispatchDelay(model: PrecipitationScreenViewModel) -> Double? {
        nil
}
}

private class SetStatement: PrecipitationScreenState {
    init(_ statement: [TextLine]) {
        self.statement = statement
    }

    private let statement: [TextLine]

    override func apply(on model: PrecipitationScreenViewModel) {
        model.statement = statement
    }
}
