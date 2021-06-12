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
        EndOfWeakAcidReaction(),
        PostWeakAcidReaction(),
        SetStatement(statements.explainBufferSolutions),
        SetStatement(statements.explainBufferSolutions2),
        SetStatement(statements.explainBufferUses),
        ShowFractionChart(),
        SetStatement(statements.explainFractionChartCurrentPosition),
        SetStatement(statements.explainBufferRange),
        SetStatement(statements.explainBufferProportions),
        SetStatement(statements.explainAddingAcidIonizingSalt),
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
        model.equationState = .weakAcidWithSubstanceConcentration
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.input = .none
        model.equationState = .weakAcidBlank
    }
}

private class RunWeakAcidReaction: BufferScreenState {

    private let reactionDuration = 3.0

    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.runningWeakAcidReaction(model.substance)
        model.equationState = .weakAcidWithAllConcentration
        withAnimation(.linear(duration: reactionDuration)) {
            model.weakSubstanceModel.progress = 1
        }

        withAnimation(.easeOut(duration: 0.35)) {
            model.input = .none
            model.shakeModel.activeMolecule = nil
        }
    }

    override func nextStateAutoDispatchDelay(model: BufferScreenViewModel) -> Double? {
        reactionDuration
    }
}

private class EndOfWeakAcidReaction: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.weakAcidEquilibriumReached(
            substance: model.substance,
            ka: model.weakSubstanceModel.substance.kA,
            pH: model.weakSubstanceModel.pH.getY(at: 1)
        )
        model.equationState = .weakAcidFilled
        withAnimation(.easeOut(duration: 0.5)) {
            model.weakSubstanceModel.progress = 1.0001
        }
    }
}

private class PostWeakAcidReaction: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.introduceBufferSolutions
        model.equationState = .acidSummary
    }
}

private class ShowFractionChart: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.explainFractionChart(substance: model.substance)
        model.selectedBottomGraph = .curve
    }
}

private class AddSalt: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.instructToAddSalt
        model.goToAddSaltPhase()
        model.input = .addMolecule(phase: .addSalt)
    }
}

private class AddAcid: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = ["Now, add strong acid"]
        model.goToStrongSubstancePhase()
        model.input = .addMolecule(phase: .addStrongSubstance)
    }
}
