//
// Reactions App
//

import SwiftUI
import ReactionsCore

private let statements = TitrationStatements.self

struct TitrationNavigationModel {
    private init() { }

    static func model(
        _ viewModel: TitrationViewModel,
        namePersistence: NamePersistence
    ) -> NavigationModel<TitrationScreenState> {
        NavigationModel(model: viewModel, states: states(namePersistence: namePersistence))
    }

    private static func states(namePersistence: NamePersistence) -> [TitrationScreenState] {
//        strongAcidTitration +
//            strongBaseTitration +
//            weakAcidTitration(namePersistence: namePersistence) +
            weakBaseTitration(namePersistence: namePersistence)
    }

    private static let strongAcidTitration: [TitrationScreenState] = [
        PrepareNewSubstanceModel(statements.intro, substance: .strongAcid),
        StopInput(statements.explainNeutralization),
        SetStatement(statements.explainMolecularIonicEquations),
        SetStatement(statements.explainTitration),
        SetStatement(statements.explainEquivalencePoint),
        SetWaterLevel(statements.explainTitrationCurveAndInstructToSetWaterLevel),
        AddSubstance(\.instructToAddStrongAcid, equation: .strongAcidAddingSubstance),
        StopInput(statements.explainTitrationStages),
        SetStatement(statements.explainMolesOfHydrogen),
        ShowMacroscopicBeaker(statements.explainIndicator),
        AddIndicator(statements.instructToAddIndicator),
        SetTitrantMolarity(
            statements.instructToSetMolarityOfStrongBaseTitrant,
            equation: .strongAcidPreEPFilled
        ),
        AddTitrantPreEP(\.instructToAddStrongBaseTitrant),
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
        AddSubstance(\.instructToAddStrongBase, equation: .strongBaseAddingSubstance),
        StopInput(statements.postAddingStrongBaseExplanation1),
        SetStatement(statements.postAddingStrongBaseExplanation2),
        AddIndicator(statements.instructToAddIndicator),
        SetTitrantMolarity(
            statements.instructToSetMolarityOfStrongBaseTitrant,
            equation: .strongBasePreEPFilled
        ),
        AddTitrantPreEP(\.instructToAddStrongBaseTitrant),
        StopInput(statements.reachedStrongAcidEquivalencePoint),
        AddTitrantPostEP(
            statements.instructToAddStrongAcidTitrantPostEP,
            equation: .strongBasePostEP
        ),
        StopInput(statements.endOfStrongBaseTitration)
    ]

    private static func weakAcidTitration(namePersistence: NamePersistence) -> [TitrationScreenState] {
        [
            PrepareNewSubstanceModel(
                statements.instructToChooseWeakAcid,
                substance: .weakAcid,
                equation: .weakAcidBlank
            ),
            SetWaterLevel(statements.instructToSetWeakAcidTitrationWaterLevel),
            StopInput(\.explainWeakAcidTitrationReaction),
            AddSubstance(\.instructToAddWeakAcid, equation: .weakAcidAddingSubstance),
            RunWeakSubstanceInitialReaction(statements.runningWeakAcidReaction),
            EndOfWeakSubstanceInitialReaction(
                { model in
                    TitrationSubstanceStatements(
                        substance: model.substance,
                        namePersistence: model.namePersistence
                    ).endOfWeakAcidReaction(
                        kA: model.substance.kA,
                        pH: model.weakPrep.currentPH,
                        substanceMoles: model.components.weakSubstancePreparationModel.currentSubstanceMoles
                    )
                },
                equation: .weakAcidPostInitialReaction
            ),
            SetStatement(\.explainWeakAcidTitrationStages),
            SetStatement(statements.explainIndicator),
            AddIndicator(
                statements.instructToAddIndicator,
                equation: .weakAcidPreEPBlank
            ),
            SetTitrantMolarity(
                statements.instructToSetMolarityOfTitrantOfWeakAcidSolution,
                equation: .weakAcidPreEPFilled
            ),
            StopInput(\.explainWeakAcidBufferRegion),
            SetStatement(\.explainWeakAcidHasselbalch),
            SetStatement(\.explainWeakAcidBufferMoles),
            AddTitrantPreEP(\.instructToAddTitrantToWeakAcid),
            StopInput(\.reachedWeakAcidMaxBufferCapacity),
            AddTitrantToWeakSubstancePostMaxBufferCapacity(
                \.instructToAddTitrantToWeakAcidPostMaxBufferCapacity
            ),
            StopInput(
                { model in
                    TitrationSubstanceStatements(
                        substance: model.substance,
                        namePersistence: model.namePersistence
                    ).reachedWeakAcidEquivalencePoint(
                        pH: model.weakPreEP.currentPH
                    )
                }
            ),
            SetStatement(\.explainWeakAcidEP1, equation: .weakAcidAtEP),
            SetStatement(
                { model in
                    statements.explainWeakAcidEP2(pH: model.weakPreEP.currentPH)
                }
            ),
            AddTitrantPostEP(statements.instructToAddTitrantToWeakAcidPostEP, equation: .weakAcidPostEPPreAddingTitrant),
            StopInput(statements.endOfWeakAcidTitration, namePersistence: namePersistence)
        ]
    }

    private static func weakBaseTitration(namePersistence: NamePersistence) -> [TitrationScreenState] {
        [
            PrepareNewSubstanceModel(
                statements.instructToChooseWeakBase,
                substance: .weakBase,
                equation: .weakBaseBlank
            ),
            SetWaterLevel(statements.instructToSetWaterLevelOfWeakBaseTitration),
            AddSubstance(\.instructToAddWeakBase, equation: .weakBaseAddingSubstance),
            RunWeakSubstanceInitialReaction(statements.runningWeakAcidReaction),
            EndOfWeakSubstanceInitialReaction(
                { model in
                    TitrationSubstanceStatements(
                        substance: model.substance,
                        namePersistence: model.namePersistence
                    ).endOfWeakBaseReaction(
                        kB: model.substance.kB,
                        pOH: 14 - model.weakPrep.currentPH,
                        substanceMoles: model.components.weakSubstancePreparationModel.currentSubstanceMoles
                    )
                },
                equation: .weakBasePostInitialReaction
            ),
            SetStatement(\.explainWeakBaseTitrationStages),
            SetStatement(statements.explainIndicator),
            AddIndicator(
                statements.instructToAddIndicator,
                equation: .weakBasePreEPBlank
            ),
            SetTitrantMolarity(
                statements.instructToSetMolarityTitrantOfWeakBaseSolution,
                equation: .weakBasePreEPFilled
            ),
            StopInput(\.explainWeakBaseBufferRegion),
            SetStatement(\.explainWeakBaseHasselbalch),
            SetStatement(\.explainWeakBaseBufferMoles),
            AddTitrantPreEP(\.instructToAddTitrantToWeakBase),
            StopInput(\.reachedWeakBaseMaxBufferCapacity),
            AddTitrantToWeakSubstancePostMaxBufferCapacity(
                \.instructToAddTitrantToWeakBasePostMaxBufferCapacity
            ),
            StopInput(
                { model in
                    TitrationSubstanceStatements(
                        substance: model.substance,
                        namePersistence: model.namePersistence
                    ).reachedWeakBaseEquivalencePoint(
                        pH: model.weakPreEP.currentPH
                    )
                }
            ),
            SetStatement(\.explainWeakBaseEP1, equation: .weakBaseAtEP),
            SetStatement(
                { model in
                    statements.explainWeakBasedEP2(pH: model.weakPreEP.currentPH)
                }
            ),
            AddTitrantPostEP(statements.instructToAddTitrantToWeakBasePostEP, equation: .weakBasePostEPPreAddingTitrant),
            SaveWeakModelTitrantInput(statements.endOfWeakBaseTitration, namePersistence: namePersistence)
        ]
    }
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

    init(
        _ statement: [TextLine],
        equation: TitrationViewModel.EquationState? = nil,
        highlights: [TitrationScreenElement] = []
    ) {
        self.getStatement = { _ in statement }
        self.equationState = equation
        self.highlights = highlights
    }

    init(
        _ statement: @escaping (TitrationViewModel) -> [TextLine],
        equation: TitrationViewModel.EquationState? = nil,
        highlights: [TitrationScreenElement] = []
    ) {
        self.getStatement = statement
        self.equationState = equation
        self.highlights = highlights
    }

    init(
        _ statementKeyPath: KeyPath<TitrationSubstanceStatements, [TextLine]>,
        equation: TitrationViewModel.EquationState? = nil,
        highlights: [TitrationScreenElement] = []
    ) {
        self.getStatement = { model in
            TitrationSubstanceStatements(
                substance: model.substance,
                namePersistence: model.namePersistence
            )[keyPath: statementKeyPath]
        }
        self.equationState = equation
        self.highlights = highlights
    }

    init(
        _ statement: @escaping (NamePersistence) -> [TextLine],
        namePersistence: NamePersistence,
        highlights: [TitrationScreenElement] = []
    ) {
        self.getStatement = { model in
            statement(model.namePersistence)
        }
        self.equationState = nil
        self.highlights = highlights
    }

    private let getStatement: (TitrationViewModel) -> [TextLine]
    private let equationState: TitrationViewModel.EquationState?
    private let highlights: [TitrationScreenElement]

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
        model.highlights.clear()
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
        model.showIndicatorFill = false
        model.showTitrantFill = false

        if !model.components.state.substance.isStrong {
            model.showPhString = false
        }

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
        model.highlights.elements = [.reactionSelection]
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        model.inputState = .none
        model.showTitrantFill = true
        model.showIndicatorFill = true
        model.showPhString = true
        model.substanceSelectionIsToggled = false
        if let previousSelectedSubstance = previousSelectedSubstance,
           let previousSubstance = previousSubstance {
            model.substance = previousSelectedSubstance
            model.availableSubstances = availableSubstances(forSubstance: previousSubstance)
            model.components.assertGoTo(state: .init(substance: previousSubstance, phase: .postEP))

            withAnimation(containerInputAnimation) {
                model.rows = model.components.latestPreparationModel.exactRows
            }
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
        DeferScreenEdgesState.shared.deferEdges = []
        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
        }
    }
}

private class SetWaterLevel: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        doApply(on: model)
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        doApply(on: model)
    }

    private func doApply(on model: TitrationViewModel) {
        model.inputState = .setWaterLevel
        model.substanceSelectionIsToggled = false
        model.highlights.elements = [.waterSlider]
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        model.inputState = .none
    }
}

private class AddSubstance: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        commonApply(on: model)
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        commonApply(on: model)
        withAnimation(containerInputAnimation) {
            model.resetInitialSubstance()
        }
    }

    private func commonApply(on model: TitrationViewModel) {
        model.inputState = .addSubstance
        model.highlights.elements = [.container]
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        model.inputState = .none
        model.highlights.clear()
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
        DeferScreenEdgesState.shared.deferEdges = []
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
        model.highlights.elements = [.burette]
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

private class AddTitrantToWeakSubstancePostMaxBufferCapacity: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        doApply(on: model)
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        doApply(on: model)
        let weakModel = model.components.weakSubstancePreEPModel
        withAnimation(.easeOut(duration: 0.35)) {
            weakModel.resetReactionProgressToMaxBufferCapacity()
            weakModel.titrantAdded = weakModel.titrantAtMaxBufferCapacity
        }
    }

    private func doApply(on model: TitrationViewModel) {
        model.inputState = .addTitrant
        model.components.weakSubstancePreEPModel.titrantLimit = .equivalencePoint
    }

    override func unapply(on model: TitrationViewModel) {
        model.inputState = .none
        model.components.weakSubstancePreEPModel.titrantLimit = .maxBufferCapacity
        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
        }
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
        model.highlights.elements = [.burette]
        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
        }
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        let currentSubstance = model.components.state.substance
        model.inputState = .none
        model.components.assertGoTo(state: .init(substance: currentSubstance, phase: .preEP))
        model.highlights.clear()

        withAnimation(containerInputAnimation) {
            model.shakeModel.stopAll()
        }
    }
}

private class ShowMacroscopicBeaker: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        doApply(on: model)
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        doApply(on: model)
    }

    private func doApply(on model: TitrationViewModel) {
        model.highlights.elements = [.macroscopicBeaker]
        model.beakerState = .macroscopic
    }
}

private class AddIndicator: SetStatement {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        commonApply(on: model)
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        commonApply(on: model)
        withAnimation(containerInputAnimation) {
            model.resetIndicator()
        }
    }

    private func commonApply(on model: TitrationViewModel) {
        model.inputState = .addIndicator
        model.highlights.elements = [.indicator]
        model.showIndicatorFill = true
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        withAnimation(containerInputAnimation) {
            model.inputState = .none
            model.resetIndicator()
            model.showIndicatorFill = false
        }
        model.highlights.clear()
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
        model.highlights.elements = [.burette]
        DeferScreenEdgesState.shared.deferEdges = [.top]
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        model.showTitrantFill = false
        model.highlights.clear()
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
        model.showPhString = true
    }

    override func reapply(on model: TitrationViewModel) {
        super.reapply(on: model)
        model.showPhString = true
    }

    override func unapply(on model: TitrationViewModel) {
        super.unapply(on: model)
        model.showPhString = false
    }
}

private class SaveWeakModelTitrantInput: StopInput {
    override func apply(on model: TitrationViewModel) {
        super.apply(on: model)
        let weakModel = model.components.weakSubstancePreparationModel
        let input = TitrationScreenInput(
            weakBase: weakModel.substance,
            weakBaseBeakerRows: GridCoordinateList.availableRows(for: model.rows),
            weakBaseSubstanceAdded: weakModel.substanceAdded,
            titrantMolarity: weakModel.titrantMolarity
        )
        model.titrationPersistence.input = input
    }
}
