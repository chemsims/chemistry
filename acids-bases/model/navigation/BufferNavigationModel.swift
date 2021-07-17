//
// Reactions App
//

import SwiftUI
import ReactionsCore

private let statements = BufferStatements.self
private func substanceStatements(_ model: BufferScreenViewModel) -> BufferStatementsForSubstance {
    BufferStatementsForSubstance(
        substance: model.substance,
        namePersistence: model.namePersistence,
        strongAcid: model.strongAcid,
        strongBase: model.strongBase
    )
}

struct BufferNavigationModel {
    private init() { }

    static func model(_ viewModel: BufferScreenViewModel) -> NavigationModel<BufferScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states = [
        // MARK: Weak acid buffer
        SetStatement(statements.intro),
        SetStatement(statements.explainEquilibriumConstant1),
        SelectWeakAcid(),
        PostSelectSubstance(statements.explainWeakAcid, highlights: [.reactionDefinition]),
        SetStatement(statements.explainKa, highlights: [.kEquation]),
        SetStatement(statements.explainHighKa),
        SetStatement(statements.explainConjugateBase),
        SetStatement(statements.explainKb),
        SetStatement(statements.explainKw),
        SetStatement(statements.explainP14),
        SetStatement(statements.explainKaKbNaming, highlights: [.kWEquation]),
        SetStatement(statements.explainPKaPKb, highlights: [.pKEquation]),
        SetStatement(statements.explainHendersonHasselbalch, highlights: [.hasselbalchEquation]),
        SetWaterLevel(statements.instructToSetWaterLevel1),
        AddWeakAcid(),
        RunWeakAcidReaction(),
        EndOfWeakAcidReaction(),
        PostWeakAcidReaction(),
        SetStatement(statements.explainBufferSolutions),
        SetStatement(statements.explainBufferSolutions2),
        SetStatement(statements.explainBufferUses),
        ShowFractionChart(statements.explainFractionChart),
        SetStatement(statements.explainFractionChartCurrentPosition),
        SetStatement(statements.explainBufferRange),
        SetStatement(statements.explainBufferProportions),
        SetStatement(statements.explainAddingAcidIonizingSalt),
        AddSalt(statements.instructToAddSalt),
        PostAdd(fromSubstance: \.reachedAcidBuffer),
        SetStatement(fromSubstance: \.showPreviousPhLine, highlights: [.topChart]),
        AddStrongSubstance(fromSubstance: \.instructToAddStrongAcid),
        PostAdd(statements.acidBufferLimitReached),

        // MARK: Weak base buffer
        SelectWeakBase(),
        PostSelectSubstance(fromSubstance: \.choseWeakBase, highlights: [.reactionDefinition]),
        SetStatement(fromSubstance: \.explainKbEquation, highlights: [.kEquation]),
        SetStatement(statements.explainKbOhRelation),
        SetStatement(fromSubstance: \.explainConjugateAcidPair),
        SetStatement(fromSubstance: \.explainKa),
        SetStatement(fromSubstance: \.explainBasicHasselbalch, highlights: [.hasselbalchEquation]),
        SetWaterLevel(statements.instructToSetWaterLevelForBase),
        AddWeakBase(),
        RunWeakBaseReaction(),
        EndOfWeakBaseReaction(),
        PostWeakBaseReaction(),
        ShowFractionChart(fromSubstance: \.explainBufferRange),
        SetStatement(fromSubstance: \.calculateBufferRange),
        SetStatement(fromSubstance: \.explainEqualProportions),
        SetStatement(fromSubstance: \.explainSalt),
        AddSalt(fromSubstance: \.instructToAddSaltToBase),
        PostAdd(fromSubstance: \.reachedBasicBuffer),
        SetStatement(fromSubstance: \.showBasePhWaterLine, highlights: [.topChart]),
        AddStrongSubstance(fromSubstance: \.instructToAddStrongBase),
        PostAdd(statements.baseBufferLimitReached)
    ]
}

private let containerInputAnimation = Animation.easeOut(duration: 0.35)
private let endReactionAnimation = Animation.easeOut(duration: 0.5)

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

    init(_ statement: [TextLine], highlights: [BufferScreenElement] = []) {
        self.statement = { _ in statement }
        self.highlights = highlights

    }

    init(_ statement: @escaping (AcidOrBase) -> [TextLine], highlights: [BufferScreenElement] = []) {
        self.statement = { statement($0.substance) }
        self.highlights = highlights
    }

    init(fromSubstance keyPath: KeyPath<BufferStatementsForSubstance, [TextLine]>, highlights: [BufferScreenElement] = []) {
        self.statement = {
            substanceStatements($0)[keyPath: keyPath]
        }
        self.highlights = highlights
    }

    let statement: (BufferScreenViewModel) -> [TextLine]
    let highlights: [BufferScreenElement]

    override func apply(on model: BufferScreenViewModel) {
        model.statement = statement(model)
        model.highlights.elements = highlights
    }
}

private class SelectWeakAcid: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.explainEquilibriumConstant2
        model.input = .selectSubstance
        model.substanceSelectionIsToggled = true
        model.highlights.elements = [.reactionSelection]
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.input = .none
        model.substanceSelectionIsToggled = false
        model.highlights.clear()
    }
}

private class PostSelectSubstance: SetStatement {
    override func apply(on model: BufferScreenViewModel) {
        super.apply(on: model)
        model.substanceSelectionIsToggled = false
        model.input = .none
    }
}

private class SetWaterLevel: SetStatement {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statement(model)
        model.input = .setWaterLevel
        model.highlights.elements = [.waterSlider]
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.input = .none
        model.highlights.clear()
    }
}

private class AddWeakAcid: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = substanceStatements(model).instructToAddWeakAcid
        model.input = .addMolecule(phase: .addWeakSubstance)
        model.equationState = .acidWithSubstanceConcentration
        model.highlights.elements = [.containers]
    }

    override func reapply(on model: BufferScreenViewModel) {
        model.weakSubstanceModel.resetCoords()
        apply(on: model)
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.input = .none
        model.equationState = .acidBlank
        model.weakSubstanceModel.resetCoords()
        model.shakeModel.stopAll()
        model.highlights.clear()
    }
}

private class RunWeakSubstanceReaction: BufferScreenState {
    private let reactionDuration = 3.0

    override func apply(on model: BufferScreenViewModel) {
        withAnimation(.linear(duration: reactionDuration)) {
            model.weakSubstanceModel.progress = 1
        }

        model.highlights.clear()
        model.weakSubstanceModel.runReactionProgressReaction()

        withAnimation(containerInputAnimation) {
            model.input = .none
            model.shakeModel.stopAll()
        }
    }

    override func reapply(on model: BufferScreenViewModel) {
        model.weakSubstanceModel.resetReactionProgress()
        super.reapply(on: model)
    }

    override func unapply(on model: BufferScreenViewModel) {
        withAnimation(containerInputAnimation) {
            model.weakSubstanceModel.resetReactionProgress()
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
    }
}

private class EndOfWeakAcidReaction: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.weakAcidEquilibriumReached(
            substance: model.substance,
            ka: model.weakSubstanceModel.substance.kA,
            pH: model.weakSubstanceModel.pH.getY(at: 1)
        )
        model.equationState = .acidFilled
        withAnimation(endReactionAnimation) {
            model.weakSubstanceModel.progress = 1.0001
        }
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.equationState = .acidWithSubstanceConcentration
    }
}

private class PostWeakAcidReaction: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.introduceBufferSolutions
        model.equationState = .acidSummary
        model.goToSaltPhase()
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.phase = .addWeakSubstance
        if model.selectedBottomGraph == .curve {
            model.selectedBottomGraph = .bars
        }
    }
}

private class ShowFractionChart: SetStatement {
    override func apply(on model: BufferScreenViewModel) {
        super.apply(on: model)
        model.selectedBottomGraph = .curve
        model.highlights.elements = [.fractionChart]
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.highlights.clear()
    }
}

private class AddSalt: SetStatement {
    override func apply(on model: BufferScreenViewModel) {
        super.apply(on: model)
        model.input = .addMolecule(phase: .addSalt)
        model.highlights.elements = [.containers]
    }

    override func reapply(on model: BufferScreenViewModel) {
        withAnimation(containerInputAnimation) {
            model.saltModel.reset()
        }
        apply(on: model)
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.input = .none
        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
            model.saltModel.reset()
        }
        model.highlights.clear()
    }
}

private class PostAdd: SetStatement {
    override func apply(on model: BufferScreenViewModel) {
        super.apply(on: model)
        withAnimation(containerInputAnimation) {
            model.input = .none
            model.shakeModel.stopAll()
        }
        model.highlights.clear()
    }
}

private class AddStrongSubstance: SetStatement {
    override func apply(on model: BufferScreenViewModel) {
        model.goToStrongSubstancePhase()
        doApply(on: model)
    }

    override func reapply(on model: BufferScreenViewModel) {
        withAnimation(containerInputAnimation) {
            model.strongSubstanceModel.reset()
        }
        doApply(on: model)
    }

    private func doApply(on model: BufferScreenViewModel) {
        super.apply(on: model)
        model.input = .addMolecule(phase: .addStrongSubstance)
        model.highlights.elements = [.containers]
    }

    override func unapply(on model: BufferScreenViewModel) {
        withAnimation(containerInputAnimation) {
            model.input = .none
            model.shakeModel.stopAll()
            model.strongSubstanceModel.reset()
        }
        model.phase = .addSalt
        model.highlights.clear()
    }
}

private class SelectWeakBase: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.saveAcidModels()
        model.availableSubstances = AcidOrBase.weakBases
        model.goToWeakSubstancePhase()
        doApply(on: model)
    }

    override func reapply(on model: BufferScreenViewModel) {
        doApply(on: model)
    }

    private func doApply(on model: BufferScreenViewModel) {
        model.statement = statements.instructToChooseWeakBase
        model.input = .selectSubstance
        model.substanceSelectionIsToggled = true
        model.equationState = .baseBlank
        model.highlights.elements = [.reactionSelection]
        if model.selectedBottomGraph == .curve {
            model.selectedBottomGraph = .bars
        }
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.equationState = .acidSummary
        model.input = .none
        model.substanceSelectionIsToggled = false
        model.restoreSavedAcidModels()
        model.phase = .addStrongSubstance
        model.highlights.clear()
        model.availableSubstances = AcidOrBase.weakAcids
    }
}

private class AddWeakBase: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = substanceStatements(model).instructToAddWeakBase
        model.input = .addMolecule(phase: .addWeakSubstance)
        model.equationState = .baseWithSubstanceConcentration
        model.highlights.elements = [.containers]
    }

    override func reapply(on model: BufferScreenViewModel) {
        model.weakSubstanceModel.resetCoords()
        apply(on: model)
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.input = .none
        model.equationState = .baseBlank
        model.weakSubstanceModel.resetCoords()
        model.shakeModel.stopAll()
        model.highlights.clear()
    }
}

private class RunWeakBaseReaction: RunWeakSubstanceReaction {
    override func apply(on model: BufferScreenViewModel) {
        super.apply(on: model)
        model.statement = substanceStatements(model).runningWeakBaseReaction
        withAnimation(containerInputAnimation) {
            model.input = .none
            model.shakeModel.stopAll()
        }
    }
}

private class EndOfWeakBaseReaction: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        let finalPh = model.weakSubstanceModel.pH.getY(at: 1)
        model.statement = substanceStatements(model).reachedBaseEquilibrium(pH: finalPh)
        model.equationState = .baseFilled
        withAnimation(.easeOut(duration: 0.5)) {
            model.weakSubstanceModel.progress = 1.0001
        }
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.equationState = .baseWithSubstanceConcentration
    }
}

private class PostWeakBaseReaction: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = statements.explainBasicHasselbalch
        model.equationState = .baseSummary
        model.goToSaltPhase()
    }

    override func unapply(on model: BufferScreenViewModel) {
        model.phase = .addWeakSubstance
        if model.selectedBottomGraph == .curve {
            model.selectedBottomGraph = .bars
        }
    }
}

private class AddStrongBase: BufferScreenState {
    override func apply(on model: BufferScreenViewModel) {
        model.statement = substanceStatements(model).instructToAddStrongBase
        model.goToStrongSubstancePhase()
        model.input = .addMolecule(phase: .addStrongSubstance)
    }
}
