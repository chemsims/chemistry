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
//        SetStatement(statements.intro),
//        SetStatement(statements.explainEquilibriumConstant1),
        SelectWeakAcid(),
//        SetStatement(statements.explainWeakAcid),
//        SetStatement(statements.explainKa),
//        SetStatement(statements.explainHighKa),
//        SetStatement(statements.explainConjugateBase),
//        SetStatement(statements.explainKb),
//        SetStatement(statements.explainKw),
//        SetStatement(statements.explainP14),
//        SetStatement(statements.explainKaKbNaming),
//        SetStatement(statements.explainPKaPKb),
//        SetStatement(statements.explainHendersonHasselbalch),
//        SetWaterLevel(statements.instructToSetWaterLevel1),
        AddWeakAcid(),
        RunWeakAcidReaction(),
        EndOfWeakAcidReaction(),
        PostWeakAcidReaction(),
//        SetStatement(statements.explainBufferSolutions),
//        SetStatement(statements.explainBufferSolutions2),
//        SetStatement(statements.explainBufferUses),
//        ShowFractionChart(),
//        SetStatement(statements.explainFractionChartCurrentPosition),
//        SetStatement(statements.explainBufferRange),
//        SetStatement(statements.explainBufferProportions),
//        SetStatement(statements.explainAddingAcidIonizingSalt),
        AddSalt(),
        AddAcid(),
        AddWeakBase(),
        RunWeakBaseReaction(),
        EndOfWeakBaseReaction(),
        AddSaltToBase(),
        AddStrongBase()
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

private class SelectWeakAcid: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.explainEquilibriumConstant2
        model.input = .selectWeakAcid
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.input = .none
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

private class RunWeakSubstanceReaction: BufferScreenState {
    private let reactionDuration = 3.0

    override func apply(on model: BufferScreenViewModel) {
        withAnimation(.linear(duration: reactionDuration)) {
            model.weakSubstanceModel.progress = 1
        }

        model.weakSubstanceModel.runReactionProgressReaction(duration: reactionDuration)

        withAnimation(.easeOut(duration: 0.35)) {
            model.input = .none
            model.shakeModel.activeMolecule = nil
        }
    }

    override func nextStateAutoDispatchDelay(model: BufferScreenViewModel) -> Double? {
        reactionDuration
    }
}

private class RunWeakAcidReaction: RunWeakSubstanceReaction {
    override func apply(on model: BufferScreenViewModel) {
        super.apply(on: model)
        model.statement = statements.runningWeakAcidReaction(model.substance)
        model.equationState = .weakAcidWithAllConcentration
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
        model.goToAddSaltPhase()
    }
}

private class ShowFractionChart: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.explainFractionChart(substance: model.substance)
        model.selectedBottomGraph = .curve
    }

    override func unapply(on model: BufferScreenViewModel) {
        if model.selectedBottomGraph == .curve {
            model.selectedBottomGraph = .bars
        }
    }
}

private class AddSalt: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.instructToAddSalt
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

private class AddWeakBase: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = ["Now, add weak base"]
        model.goToWeakBufferPhase()
//        model.shakeModel.activeMolecule = nil
        model.input = .addMolecule(phase: .addWeakSubstance)
        if model.selectedBottomGraph == .curve {
            model.selectedBottomGraph = .bars
        }
        model.equationState = .weakBaseWithSubstanceConcentration
    }
}

private class RunWeakBaseReaction: RunWeakSubstanceReaction {
    override func apply(on model: BufferScreenViewModel) {
        super.apply(on: model)
        model.statement = ["Running weak base reaction"]
        model.equationState = .weakBaseWithSubstanceConcentration
    }
}

private class EndOfWeakBaseReaction: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = ["Reaction is done"]
        model.equationState = .weakBaseFilled
        withAnimation(.easeOut(duration: 0.5)) {
            model.weakSubstanceModel.progress = 1.0001
        }
    }
}

private class AddSaltToBase: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = ["Now, add salt"]
        model.goToAddSaltPhase()
        model.input = .addMolecule(phase: .addSalt)
    }
}

private class AddStrongBase: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = ["Now, add strong base"]
        model.goToStrongSubstancePhase()
        model.input = .addMolecule(phase: .addStrongSubstance)
    }
}
