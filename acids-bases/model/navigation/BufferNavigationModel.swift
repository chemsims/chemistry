//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferNavigationModel {
    private init() { }

    static func model(_ viewModel: BufferScreenViewModel) -> NavigationModel<BufferScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states = [
        SetStatement(statement: ["Press next to start reaction"]),
        RunWeakAcidReaction(),
        EndWeakAcidReaction(),
        AddSalt(),
        AddAcid()
    ]
}

class BufferScreenState: ScreenState, SubState {

    typealias Model = BufferScreenViewModel
    typealias NestedState = BufferScreenState

    func apply(on model: BufferScreenViewModel) {
    }

    func reapply(on model: BufferScreenViewModel) {
        apply(on: model)
    }

    func unapply(on model: BufferScreenViewModel) {
    }

    func delayedStates(model: BufferScreenViewModel) -> [DelayedState<BufferScreenState>] {
        []
    }

    func nextStateAutoDispatchDelay(model: BufferScreenViewModel) -> Double? {
        nil
    }
}

private class SetStatement: BufferScreenState {
    init(statement: [TextLine]) {
        self.statement = statement
    }
    let statement: [TextLine]

    override func apply(on model: BufferScreenViewModel) {
        model.statement = statement
    }
}

private class RunWeakAcidReaction: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = ["Running reaction"]
        withAnimation(.linear(duration: 2)) {
            model.weakSubstanceModel.progress = 1
        }
    }
}

private class EndWeakAcidReaction: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = ["Finished reaction"]
        withAnimation(.easeOut(duration: 0.5)) {
            model.weakSubstanceModel.progress = 1.0001
        }
    }
}

private class AddSalt: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = ["Now, add salt"]
        model.goToPhase2()
    }
}

private class AddAcid: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = ["Now, add strong acid"]
        model.goToPhase3()
    }
}
