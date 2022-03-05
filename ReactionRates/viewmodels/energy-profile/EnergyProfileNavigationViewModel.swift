//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct EnergyProfileNavigationViewModel {
    static func model(
        _ energyViewModel: EnergyProfileViewModel,
        persistence: EnergyProfilePersistence
    ) -> NavigationModel<EnergyProfileState> {
        NavigationModel(
            model: energyViewModel,
            states: states(persistence: persistence)
        )
    }

    private static func states(persistence: EnergyProfilePersistence) -> [EnergyProfileState] {
        [
            ExplanationState(
                EnergyProfileStatements.intro,
                [.reactionToggle]
            ),
            IntroToCollisionTheory(),
            ExplanationState(
                EnergyProfileStatements.explainCollisionTheory,
                []
            ),
            ExplanationState(
                EnergyProfileStatements.explainActivationEnergy,
                [.eaTerms]
            ),
            ExplanationState(
                EnergyProfileStatements.explainArrhenius,
                [.rateEquation]
            ),
            ExplanationState(
                EnergyProfileStatements.explainTerms,
                [.rateEquation]
            ),
            ExplanationState(
                EnergyProfileStatements.explainRateTempRelation,
                [.rateEquation]
            ),
            ExplanationState(
                EnergyProfileStatements.explainLinearKEquation,
                [.rateAndLinearRateEquation]
            ),
            ExplanationState(
                EnergyProfileStatements.explainArrheniusTwoPoints,
                [.rateAndLinearAndRatioEquation]
            ),
            ShowInitialEaValues(),
            ExplanationState(
                EnergyProfileStatements.explainEnergyDiagram,
                [.reactionProfileTop, .reactionProfileBottom]
            ),
            ExplainExoOrEndoThermic(),
            ExplanationState(
                EnergyProfileStatements.explainEaHump,
                [.reactionProfileTop]
            ),
            ExplainCatalyst(),
            InstructToChooseCatalyst(),
            PrepareChosenCatalyst(),
            StartShakingCatalyst(),
            StopShakingCatalyst(),
            ShowLinearChart(),
            ShowKRatio(),
            InstructToSetTemp(),

            // Second catalyst
            ReactionHasEndedSoInstructToChooseAnotherCatalyst(),
            PrepareAnotherCatalystState(),
            StartShakingCatalyst(),
            StopShakingCatalyst(),
            InstructToSetTemp(),

            // Final catalyst
            ReactionHasEndedSoInstructToChooseAnotherCatalyst(),
            PrepareAnotherCatalystState(),
            StartShakingCatalyst(),
            StopShakingCatalyst(),
            InstructToSetTemp(),
            ReactionEndedState(persistence: persistence)
        ]
    }
}

class EnergyProfileState: ScreenState, SubState {

    typealias NestedState = EnergyProfileState
    typealias Model = EnergyProfileViewModel

    let constantStatement: [TextLine]
    init(statement: [TextLine] = []) {
        self.constantStatement = statement
    }

    func statement(model: EnergyProfileViewModel) -> [TextLine] {
        constantStatement
    }

    func apply(on model: EnergyProfileViewModel) {
        model.statement = constantStatement
    }

    func unapply(on model: EnergyProfileViewModel) { }

    func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    func nextStateAutoDispatchDelay(model: EnergyProfileViewModel) -> Double? { nil }

    func delayedStates(model: EnergyProfileViewModel) -> [DelayedState<EnergyProfileState>] {
        []
    }

    var backBehaviour: NavigationModelBackBehaviour {
        .unapply
    }
}

private class IntroToCollisionTheory: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.introCollisionTheory)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.highlightedElements = []
        model.canSetReaction = false
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.canSetReaction = true
    }
}

private class ExplanationState: EnergyProfileState {
    init(
        _ statement: [TextLine],
        _ highlightedElements: [EnergyProfileScreenElement]
    ) {
        self.highlightedElements = highlightedElements
        super.init(statement: statement)
    }

    private let highlightedElements: [EnergyProfileScreenElement]

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.highlightedElements = highlightedElements
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.highlightedElements = []
    }
}

private class ShowInitialEaValues: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [TextLine] {
        EnergyProfileStatements.showCurrentValues(
            ea: model.activationEnergy,
            k: model.k1,
            t: model.temp1
        )
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.statement = statement(model: model)
        model.highlightedElements = [.rateRatioEquation]
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.highlightedElements = []
    }
}

private class ExplainExoOrEndoThermic: EnergyProfileState {
    override func apply(on model: EnergyProfileViewModel) {
        let isExoThermic = model.selectedReaction.energyProfileShapeSettings.isExoThermic
        let statement = isExoThermic ?
            EnergyProfileStatements.explainExothermic :
            EnergyProfileStatements.explainEndothermic
        model.statement = statement
        model.highlightedElements = [.reactionProfileBottom]
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }
}

private class ExplainCatalyst: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.explainCatalyst)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.highlightedElements = [.reactionProfileTop, .reactionProfileBottom, .catalysts]
        model.catalystState = .visible
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.highlightedElements = []
        model.catalystState = .disabled
    }
}

private class InstructToChooseCatalyst: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.instructToChooseCatalyst)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.highlightedElements = [.catalysts, .beaker]
        withAnimation(setCatalystToActive) {
            model.catalystState = .active
        }
        model.particleState = .none
        model.catalystIsShaking = false
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.highlightedElements = []
        model.catalystState = .visible
    }
}

/// Moves the chosen catalyst into the prepared state
private class PrepareChosenCatalyst: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.instructToShakeCatalyst)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        assert(!model.availableCatalysts.isEmpty)
        let catalyst = model.catalystToSelect ?? model.availableCatalysts.first!
        model.doSetCatalystInProgress(catalyst: catalyst)
        model.highlightedElements = []
    }

    override var backBehaviour: NavigationModelBackBehaviour {
        .skipAndIgnore
    }
}

private class StartShakingCatalyst: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.instructToShakeCatalyst)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.particleState = .fallFromContainer
        model.runCatalystShakingAnimation()
    }

    override func nextStateAutoDispatchDelay(model: EnergyProfileViewModel) -> Double? {
        1
    }

    override var backBehaviour: NavigationModelBackBehaviour {
        .skipAndIgnore
    }
}

private class StopShakingCatalyst: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [TextLine] {
        EnergyProfileStatements.showEaReduction(newEa: model.activationEnergy)
    }

    override func apply(on model: EnergyProfileViewModel) {
        doApply(on: model, saveCatalyst: true)
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }

    private func doApply(on model: EnergyProfileViewModel, saveCatalyst: Bool) {
        model.highlightedElements = [.reactionProfileTop, .reactionProfileBottom]
        let catalyst = model.catalystState.catalyst
        if let catalyst = catalyst {
            model.setSelectedCatalystState(catalyst: catalyst)
        }
        model.temp2 = model.temp1
        model.statement = statement(model: model)
        if saveCatalyst {
            model.saveCatalyst()
        }
    }

    override func reapply(on model: EnergyProfileViewModel) {
        doApply(on: model, saveCatalyst: false)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.removeCatalystFromStack()
        withAnimation(.easeOut(duration: 0.8)) {
            model.catalystState = .active
            model.temp2 = nil
        }
    }
}

private class ShowLinearChart: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [TextLine] {
        EnergyProfileStatements.showLinearChart(slope: model.slope)
    }

    override func apply(on model: EnergyProfileViewModel) {
        model.statement = statement(model: model)
        model.highlightedElements = [.linearChart]
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.highlightedElements = []
    }
}

private class ShowKRatio: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [TextLine] {
        EnergyProfileStatements.showKRatio(newK: model.k1, temp: model.temp1)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.statement = statement(model: model)
        model.highlightedElements = [.linearChart, .rateRatioEquation]
        model.reactionState = .pending
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.highlightedElements = []
    }
}

private class InstructToSetTemp: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.instructToSetTemp)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.temp2 = model.temp1
        model.highlightedElements = [.beaker, .tempSlider]
        model.reactionState = .running
        model.concentrationC = 0
        model.canClickNext = false
    }

    override func reapply(on model: EnergyProfileViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.temp2 = model.temp1
        }
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.temp2 = nil
        model.reactionState = .pending
        model.highlightedElements = []
        model.canClickNext = true
    }
}

private class ReactionHasEndedSoInstructToChooseAnotherCatalyst: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.finishedFirstCatalyst)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.catalystToSelect = nil
        model.reactionState = .completed
        model.highlightedElements = []
        model.concentrationC = 1
        model.catalystIsShaking = false
        withAnimation(setCatalystToActive) {
            model.catalystState = .active
        }
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
        model.particleState = .appearInBeaker
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.reactionState = .running
        model.concentrationC = 0
        if let previousCatalyst = model.usedCatalysts.last {
            model.catalystState = .selected(catalyst: previousCatalyst)
        }
    }
}

private class PrepareAnotherCatalystState: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.instructToChooseCatalyst)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        assert(!model.availableCatalysts.isEmpty)
        let catalyst = model.catalystToSelect ?? model.availableCatalysts.first!
        model.particleState = .none
        model.concentrationC = 0
        model.highlightedElements = []
        model.reactionState = .pending
        model.doSetCatalystInProgress(catalyst: catalyst)
    }

    override var backBehaviour: NavigationModelBackBehaviour {
        .skipAndIgnore
    }
}

private class ReactionEndedState: EnergyProfileState {
    init(persistence: EnergyProfilePersistence) {
        self.persistence = persistence
        super.init(statement: EnergyProfileStatements.finished)
    }

    private let persistence: EnergyProfilePersistence

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.reactionState = .completed
        model.highlightedElements = []
        model.concentrationC = 1

        let input = EnergyProfileInput(catalysts: model.usedCatalysts, order: model.selectedReaction)
        persistence.setInput(input)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.reactionState = .running
        model.concentrationC = 0
    }
}

private let setCatalystToActive = Animation.easeOut(duration: 0.75)
