//
// Reactions App
//

import ReactionsCore
import SwiftUI

class SolubilityNavigationModel {
    static func model(model: SolubilityViewModel) -> NavigationModel<SolubilityScreenState> {
        NavigationModel(
            model: model,
            states: [
                SetStatement(statement: ["Click next to add solute"]),
                AddSolute(),
                ShowSaturatedSolution(),
                AddSoluteToSaturatedBeaker()
            ]
        )
    }
}

class SolubilityScreenState: ScreenState, SubState {

    typealias Model = SolubilityViewModel
    typealias NestedState = SolubilityScreenState

    func apply(on model: SolubilityViewModel) {

    }

    func reapply(on model: SolubilityViewModel) {
        apply(on: model)
    }

    func unapply(on model: SolubilityViewModel) {

    }


    func delayedStates(model: SolubilityViewModel) -> [DelayedState<SolubilityScreenState>] {
        []
    }

    func nextStateAutoDispatchDelay(model: SolubilityViewModel) -> Double? {
        nil
    }
}

private class SetStatement: SolubilityScreenState {

    let statement: [TextLine]

    init(statement: [TextLine]) {
        self.statement = statement
    }

    override func apply(on model: SolubilityViewModel) {
        model.statement = statement
    }
}

private class AddSolute: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = ["Now, add solute"]
        model.inputState = .addSolute
    }
}

private class ShowSaturatedSolution: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = ["Solution is now saturated"]
        model.stopShaking()
        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .none
            model.activeSolute = nil
        }
    }
}

private class AddSoluteToSaturatedBeaker: SolubilityScreenState {
    override func apply(on model: SolubilityViewModel) {
        model.statement = ["Now add a little more solute"]
        withAnimation(.easeOut(duration: 0.5)) {
            model.inputState = .addSaturatedSolute
            model.activeSolute = .primary
        }
        model.startShaking()
    }
}
