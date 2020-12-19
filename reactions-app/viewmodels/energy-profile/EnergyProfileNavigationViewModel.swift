//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileNavigationViewModel {
    static func model(_ energyViewModel: EnergyProfileViewModel) -> NavigationViewModel<EnergyProfileState> {
        NavigationViewModel(
            reactionViewModel: energyViewModel,
            states: states
        )
    }

    private static let states = [
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
        ExplanationState(
            EnergyProfileStatements.explainExothermic,
            [.reactionProfileBottom]
        ),
        ExplanationState(
            EnergyProfileStatements.explainEaHump,
            [.reactionProfileTop]
        ),
        ShowCatalyst(),
        EnableCatalyst(),
        PrepareCatalyst(),
        StartShakingCatalyst(),
        StopShakingCatalyst(),
        ShowLinearChart(),
        ShowKRatio(),
        InstructToSetTemp(),
        ReactionEndedState(),
    ]
}

class EnergyProfileState: ScreenState, SubState {

    typealias NestedState = EnergyProfileState
    typealias Model = EnergyProfileViewModel

    let constantStatement: [SpeechBubbleLine]
    init(statement: [SpeechBubbleLine] = []) {
        self.constantStatement = statement
    }

    func statement(model: EnergyProfileViewModel) -> [SpeechBubbleLine] {
        constantStatement
    }

    func apply(on model: EnergyProfileViewModel) {
        model.statement = constantStatement
    }

    func unapply(on model: EnergyProfileViewModel) { }

    func reapply(on model: EnergyProfileViewModel) { }

    func nextStateAutoDispatchDelay(model: EnergyProfileViewModel) -> Double? { nil }

    let delayedStates = [DelayedState<EnergyProfileState>]()

    var ignoreOnBack: Bool {
        false
    }
}

fileprivate class IntroToCollisionTheory: EnergyProfileState {
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

fileprivate class ExplanationState: EnergyProfileState {
    init(
        _ statement: [SpeechBubbleLine],
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

fileprivate class ShowInitialEaValues: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [SpeechBubbleLine] {
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

fileprivate class ShowCatalyst: EnergyProfileState {
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

fileprivate class EnableCatalyst: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.instructToChooseCatalyst)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.highlightedElements = [.catalysts, .beaker]
        withAnimation(.easeOut(duration: 0.75)) {
            model.catalystState = .active
        }
        model.emitCatalyst = false
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

fileprivate class PrepareCatalyst: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.instructToShakeCatalyst)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        let catalyst = model.catalystState.pending ?? model.catalystState.selected ?? .C
        model.doSetCatalystInProgress(catalyst: catalyst)
        model.highlightedElements = []
    }

    override func unapply(on model: EnergyProfileViewModel) {
        withAnimation(.easeOut(duration: 0.75)) {
            model.catalystState = .active
        }
    }

    override var ignoreOnBack: Bool {
        true
    }
}

fileprivate class StartShakingCatalyst: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.instructToShakeCatalyst)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.emitCatalyst =  true
        model.runCatalystShakingAnimation()
    }

    override func unapply(on model: EnergyProfileViewModel) {
        withAnimation(.linear(duration: 0.5)) {
            model.catalystIsShaking = false
        }
        model.emitCatalyst = false
    }

    override func nextStateAutoDispatchDelay(model: EnergyProfileViewModel) -> Double? {
        1
    }

    override var ignoreOnBack: Bool {
        true
    }
}

fileprivate class StopShakingCatalyst: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [SpeechBubbleLine] {
        EnergyProfileStatements.showEaReduction(newEa: model.activationEnergy)
    }

    override func apply(on model: EnergyProfileViewModel) {
        model.statement = statement(model: model)
        model.highlightedElements = [.reactionProfileTop, .reactionProfileBottom]
        model.setSelectedCatalystState(catalyst: model.catalystState.pending ?? .C)
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        withAnimation(.easeOut(duration: 0.8)) {
            model.peakHeightFactor = 1
        }
    }
}

fileprivate class ShowLinearChart: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [SpeechBubbleLine] {
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

fileprivate class ShowKRatio: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [SpeechBubbleLine] {
        EnergyProfileStatements.showKRatio(newK: model.k2 ?? 0)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.statement = statement(model: model)
        model.highlightedElements = [.linearChart, .rateRatioEquation]
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.highlightedElements = []
    }
}

fileprivate class InstructToSetTemp: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.instructToSetTemp)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.temp2 = model.temp2 ?? model.temp1
        model.highlightedElements = [.beaker, .tempSlider]
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.temp2 = nil
        model.highlightedElements = []
    }
}

fileprivate class ReactionEndedState: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.finished)
    }

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.reactionHasEnded = true
        model.concentrationC = 1
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.reactionHasEnded = false
        model.concentrationC = 0
    }
}


