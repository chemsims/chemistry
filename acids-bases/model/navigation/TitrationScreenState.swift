//
// Reactions App
//

import SwiftUI
import ReactionsCore

private let statements = TitrationStatements.self

struct TitrationNavigationModel {
    private init() { }

    static func model(_ viewModel: TitrationViewModel) -> NavigationModel<TitrationScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states: [TitrationScreenState] =
         strongAcidTitration + strongBaseTitration + weakAcidTitration + weakBaseTitration

    private static let strongAcidTitration: [TitrationScreenState] = [
        PrepareNewSubstanceModel(statements.intro, substance: .strongAcid),
        StopInput(statements.explainNeutralization),
        SetStatement(statements.explainMolecularIonicEquations),
        SetStatement(statements.explainTitration),
        SetStatement(statements.explainEquivalencePoint),
        SetWaterLevel(statements.explainTitrationCurveAndInstructToSetWaterLevel),
        AddSubstance(statements.instructToAddStrongAcid, equation: .strongAcidAddingSubstance),
        StopInput(statements.explainTitrationStages),
        SetStatement(statements.explainMolesOfHydrogen),
        SetStatement(statements.explainIndicator),
        AddIndicator(statements.instructToAddIndicator),
        SetTitrantMolarity(
            statements.instructToSetMolarityOfStrongBaseTitrant,
            equation: .strongAcidPreEPFilled
        ),
        AddTitrantPreEP(statements.instructToAddStrongBaseTitrant),
        StopInput(statements.reachedStrongAcidEquivalencePoint),
        AddTitrantPostEP(statements.instructToAddStrongBaseTitrantPostEP, equation: .strongAcidPostEP),
        StopInput(statements.endOfStrongAcidTitration)
    ]

    private static let strongBaseTitration: [TitrationScreenState] = [
        PrepareNewSubstanceModel(
            statements.instructToChooseStrongBase,
            substance: .strongBase,
            equation: .strongBaseBlank
        ),
        SetWaterLevel(statements.instructToSetWaterLevelForStrongBaseTitration),
        AddSubstance(statements.instructToAddStrongBase, equation: .strongBaseAddingSubstance),
        StopInput(statements.postAddingStrongBaseExplanation1),
        SetStatement(statements.postAddingStrongBaseExplanation2),
        AddIndicator(statements.instructToAddIndicator),
        SetTitrantMolarity(
            statements.instructToSetMolarityOfStrongBaseTitrant,
            equation: .strongBasePreEPFilled
        ),
        AddTitrantPreEP(statements.instructToAddStrongBaseTitrant),
        StopInput(statements.reachedStrongAcidEquivalencePoint),
        AddTitrantPostEP(
            statements.instructToAddStrongAcidTitrantPostEP,
            equation: .strongBasePostEP
        ),
        StopInput(statements.endOfStrongBaseTitration)
    ]

    private static let weakAcidTitration: [TitrationScreenState] = [
        PrepareNewSubstanceModel(
            statements.instructToChooseWeakAcid,
            substance: .weakAcid,
            equation: .weakAcidBlank
        ),
        SetWaterLevel(statements.instructToSetWeakAcidTitrationWaterLevel),
        StopInput(statements.explainWeakAcidTitrationReaction),
        AddSubstance(statements.instructToAddWeakAcid, equation: .weakAcidAddingSubstance),
        RunWeakSubstanceInitialReaction(statements.runningWeakAcidReaction),
        EndOfWeakSubstanceInitialReaction(
            { model in
                statements.endOfWeakAcidReaction(
                    kA: model.substance.kA,
                    pH: model.weakPrep.currentPH,
                    substanceMoles: model.components.weakSubstancePreparationModel.currentSubstanceMoles
                )
            },
            equation: .weakAcidPostInitialReaction
        ),
        SetStatement(statements.explainWeakAcidTitrationStages),
        SetStatement(statements.explainIndicator),
        AddIndicator(
            statements.instructToAddIndicator,
            equation: .weakAcidPreEPBlank
        ),
        SetTitrantMolarity(
            statements.instructToSetMolarityOfTitrantOfWeakAcidSolution,
            equation: .weakAcidPreEPFilled
        ),
        StopInput(statements.explainWeakAcidBufferRegion),
        SetStatement(statements.explainWeakAcidHasselbalch),
        SetStatement(statements.explainWeakAcidBufferMoles),
        AddTitrantPreEP(statements.instructToAddTitrantToWeakAcid),
        StopInput(
            { model in
                statements.reachedWeakAcidEquivalencePoint(
                    pH: model.weakPreEP.currentPH
                )
            }
        ),
        SetStatement(statements.explainWeakAcidEP1),
        SetStatement(
            { model in
                statements.explainWeakAcidEP2(pH: model.weakPreEP.currentPH)
            }
        ),
        AddTitrantPostEP(statements.instructToAddTitrantToWeakAcidPostEP),
        StopInput(statements.endOfWeakAcidTitration)
    ]

    private static let weakBaseTitration: [TitrationScreenState] = [
        PrepareNewSubstanceModel(
            statements.instructToChooseWeakBase,
            substance: .weakBase,
            equation: .weakAcidBlank
        ),
        SetWaterLevel(statements.instructToSetWaterLevelOfWeakBaseTitration),
        AddSubstance(statements.instructToAddWeakBase, equation: .weakBaseAddingSubstance),
        RunWeakSubstanceInitialReaction(statements.runningWeakAcidReaction),
        EndOfWeakSubstanceInitialReaction(
            { model in
                statements.endOfWeakBaseReaction(
                    kB: model.substance.kB,
                    pOH: 14 - model.weakPrep.currentPH,
                    substanceMoles: model.components.weakSubstancePreparationModel.currentSubstanceMoles
                )
            },
            equation: .weakBasePostInitialReaction
        ),
        SetStatement(statements.explainWeakBaseTitrationStages),
        SetStatement(statements.explainIndicator),
        AddIndicator(
            statements.instructToAddIndicator,
            equation: .weakBasePreEPBlank
        ),
        SetTitrantMolarity(
            statements.instructToSetMolarityTitrantOfWeakBaseSolution,
            equation: .weakBasePreEPFilled
        ),
        StopInput(statements.explainWeakBaseBufferRegion),
        SetStatement(statements.explainWeakBaseHasselbalch),
        SetStatement(statements.explainWeakBaseBufferMoles),
        AddTitrantPreEP(statements.instructToAddTitrantToWeakBase),
        StopInput(
            { model in
                statements.reachedWeakBaseEquivalencePoint(
                    pH: model.weakPreEP.currentPH
                )
            }
        ),
        SetStatement(statements.explainWeakBaseEP1),
        SetStatement(
            { model in
                statements.explainWeakBasedEP2(pH: model.weakPreEP.currentPH)
            }
        ),
        AddTitrantPostEP(statements.instructToAddTitrantToWeakBasePostEP),
        StopInput(statements.endOfWeakBaseTitration)
    ]
}

private extension TitrationViewModel {
    var weakPrep: TitrationWeakSubstancePreparationModel {
        components.weakSubstancePreparationModel
    }
    var weakPreEP: TitrationWeakSubstancePreEPModel {
        components.weakSubstancePreEPModel
    }
}

private let containerInputAnimation = Animation.easeOut(duration: 0.35)
private let endReactionAnimation = Animation.easeOut(duration: 0.5)

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

    init(_ statement: [TextLine], equation: TitrationViewModel.EquationState? = nil) {
        self.getStatement = { _ in statement }
        self.equationState = equation
    }

    init(_ statement: @escaping (TitrationViewModel) -> [TextLine], equation: TitrationViewModel.EquationState? = nil) {
        self.getStatement = statement
        self.equationState = equation
    }

    private let getStatement: (TitrationViewModel) -> [TextLine]
    private let equationState: TitrationViewModel.EquationState?

    private var previousEquationState: TitrationViewModel.EquationState?

    override func apply(on model: TitrationViewModel) {
        if equationState != nil {
            previousEquationState = model.equationState
        }
        doApply(on: model)
    }

    override func reapply(on model: TitrationViewModel) {
        doApply(on: model)
    }

    private func doApply(on model: TitrationViewModel) {
        model.statement = getStatement(model)
        if let eqState = equationState {
            model.equationState = eqState
        }
    }

    override func unapply(on model: TitrationViewModel) {
        if let prevEqState = previousEquationState {
            model.equationState = prevEqState
        }
    }
}

private class PrepareNewSubstanceModel: SetStatement {

    init(
        _ statement: [TextLine],
        substance: TitrationComponentState.Substance,
        equation: TitrationViewModel.EquationState? = nil
    ) {
        self.substance = substance
        super.init(statement, equation: equation)
    }

    private let substance: TitrationComponentState.Substance

    private var previousSelectedSubstance: AcidOrBase?

    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)

        self.previousSelectedSubstance = model.substance

        // Don't apply state if we're already in that state
        if model.components.state != .init(substance: substance, phase: .preparation) {
            model.components.assertGoTo(state: .init(substance: substance, phase: .preparation))
        }

        model.availableSubstances = availableSubstances(forSubstance: substance)
        model.substance = model.availableSubstances.first!
        model.resetIndicator()
        model.showTitrantFill = false

        commonApply(on: model)
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        commonApply(on: model)
    }

    private func commonApply(on model: TitrationViewModel) {
        model.inputState = .selectSubstance
        model.substanceSelectionIsToggled = true
        model.macroBeakerState = .indicator
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        model.inputState = .none
        model.showTitrantFill = true
        if let previousSelectedSubstance = previousSelectedSubstance,
           let previousSubstance = previousSubstance {
            model.substance = previousSelectedSubstance
            model.availableSubstances = availableSubstances(forSubstance: previousSubstance)
            model.components.assertGoTo(state: .init(substance: previousSubstance, phase: .postEP))
        }
    }

    private var previousSubstance: TitrationComponentState.Substance? {
        TitrationComponentState.Substance.allCases.element(before: substance)
    }

    private func availableSubstances(forSubstance substance: TitrationComponentState.Substance) -> [AcidOrBase] {
        switch substance {
        case .strongAcid: return AcidOrBase.strongAcids
        case .strongBase: return AcidOrBase.strongBases
        case .weakAcid: return AcidOrBase.weakAcids
        case .weakBase: return AcidOrBase.weakBases
        }
    }
}

private class StopInput: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.inputState = .none
        model.substanceSelectionIsToggled = false
        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
        }
    }
}

private class SetWaterLevel: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.inputState = .setWaterLevel
        model.substanceSelectionIsToggled = false
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        model.inputState = .setWaterLevel
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        model.inputState = .none
    }
}

private class AddSubstance: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.inputState = .addSubstance
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        model.inputState = .addSubstance
        withAnimation(containerInputAnimation) {
            model.resetInitialSubstance()
        }
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        model.inputState = .none
        withAnimation(containerInputAnimation) {
            model.resetInitialSubstance()
            model.shakeModel.stopAll()
        }
    }
}

private class AddTitrantPreEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        let currentSubstance = model.components.state.substance
        model.components.assertGoTo(state: .init(substance: currentSubstance, phase: .preEP))
        applyCommon(on: model)
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        applyCommon(on: model)
        withAnimation(containerInputAnimation) {
            model.resetPreEPTitrant()
        }
    }

    private func applyCommon(on model: TitrationViewModel) {
        if model.components.state.substance.isStrong {
            model.macroBeakerState = .strongTitrant
        } else {
            model.macroBeakerState = .weakTitrant
        }
        withAnimation(containerInputAnimation) {
            model.inputState = .addTitrant
            model.shakeModel.stopAll()
        }
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        let currentSubstance = model.components.state.substance
        model.components.assertGoTo(state: .init(substance: currentSubstance, phase: .preparation))
        model.inputState = .none
        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
        }
        model.macroBeakerState = .indicator
    }
}

private class AddTitrantPostEP: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        let currentSubstance = model.components.state.substance
        model.components.assertGoTo(state: .init(substance: currentSubstance, phase: .postEP))
        applyCommon(on: model)
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        applyCommon(on: model)
        withAnimation(containerInputAnimation) {
            model.resetPostEPTitrant()
        }
    }

    private func applyCommon(on model: TitrationViewModel) {
        model.inputState = .addTitrant
        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
        }
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        let currentSubstance = model.components.state.substance
        model.inputState = .none
        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
            model.components.assertGoTo(state: .init(substance: currentSubstance, phase: .preEP))
        }
    }
}

private class AddIndicator: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        model.inputState = .addIndicator
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        model.inputState = .addIndicator
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        withAnimation(containerInputAnimation) {
            model.inputState = .none
            model.resetIndicator()
        }
    }
}

private class SetTitrantMolarity: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        commonApply(on: model)
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        commonApply(on: model)
    }

    private func commonApply(on model: TitrationViewModel) {
        model.inputState = .setTitrantMolarity
        model.showTitrantFill = true
        DeferScreenEdgesState.shared.deferEdges = [.top]
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        model.showTitrantFill = false
        DeferScreenEdgesState.shared.deferEdges = []
    }
}

private class RunWeakSubstanceInitialReaction: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        commonApply(on: model)
        model.inputState = .none
        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
        }
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        model.components.weakSubstancePreparationModel.reactionProgress = 0
        commonApply(on: model)
    }

    private func commonApply(on model: TitrationViewModel) {
        withAnimation(.linear(duration: AcidAppSettings.weakTitrationInitialReactionDuration)) {
            model.components.weakSubstancePreparationModel.reactionProgress = 1
        }
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        withAnimation(.easeOut(duration: 0.5)) {
            model.components.weakSubstancePreparationModel.reactionProgress = 0
        }
    }

    override func nextStateAutoDispatchDelay(model: TitrationViewModel) -> Double? {
        AcidAppSettings.weakTitrationInitialReactionDuration
    }
}

private class EndOfWeakSubstanceInitialReaction: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        withAnimation(.easeOut(duration: 0.5)) {
            model.components.weakSubstancePreparationModel.reactionProgress = 1.0001
        }
    }
}
