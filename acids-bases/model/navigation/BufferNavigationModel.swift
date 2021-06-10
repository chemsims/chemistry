//
// Reactions App
//

import SwiftUI
import ReactionsCore

private let statements = BufferStatements.self

struct BufferNavigationModel {
    private init() { }

    static func model(_ viewModel: BufferScreenViewModel) -> NavigationModel<BufferScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states = [
        SetStatement(statements.intro),
        SetStatement(statements.explainEquilibriumConstant1),
        SetStatement(statements.explainEquilibriumConstant2),
        SetStatement(statements.explainWeakAcid),
        SetStatement(statements.explainKa),
        SetStatement(statements.explainHighKa),
        SetStatement(statements.explainConjugateBase),
        SetStatement(statements.explainKb),
        SetStatement(statements.explainKw),
        SetStatement(statements.explainP14),
        SetStatement(statements.explainKaKbNaming),
        SetStatement(statements.explainPKaPKb),
        SetStatement(statements.explainHendersonHasselbalch),
        SetWaterLevel(statements.instructToSetWaterLevel1),
        AddWeakAcid(),
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
    init(_ statement: [TextLine]) {
        self.statement = { _ in statement }
    }

    init(_ statement: @escaping (AcidOrBase) -> [TextLine]) {
        self.statement = { statement($0.substance) }
    }

    let statement: (BufferScreenViewModel) -> [TextLine]

    override func apply(on model: BufferScreenViewModel) {
        model.statement = statement(model)
    }
}

private class SetWaterLevel: SetStatement {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statement(model)
        model.input = .setWaterLevel
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.input = .none
    }
}

private class AddWeakAcid: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.instructToAddWeakAcid(model.substance)
        model.input = .addMolecule(phase: .addWeakSubstance)
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.input = .none
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
        model.goToAddSaltPhase()
    }
}

private class AddAcid: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = ["Now, add strong acid"]
        model.goToPhase3()
    }
}
