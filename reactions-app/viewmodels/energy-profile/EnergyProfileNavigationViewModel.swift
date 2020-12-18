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
        ExplanationState(
            EnergyProfileStatements.introCollisionTheory,
            []
        ),
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
        ExplanationState(
            EnergyProfileStatements.explainCatalyst,
            [.reactionProfileTop, .reactionProfileBottom, .catalysts]
        ),
        ExplanationState(
            EnergyProfileStatements.instructToChooseCatalyst,
            [.catalysts, .beaker]
        ),
        ExplanationState(
            EnergyProfileStatements.instructToShakeCatalyst,
            []
        ),
        ShowUpdatedEaValues(),
        ShowLinearChart(),
        ShowKRatio(),
        ExplanationState(
            EnergyProfileStatements.instructToSetTemp,
            [.beaker, .tempSlider]
        ),
        ExplanationState(
            EnergyProfileStatements.reactionInProgress,
            []
        ),
        ExplanationState(
            EnergyProfileStatements.finished,
            []
        ),
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

    func apply(on model: EnergyProfileViewModel) { }

    func unapply(on model: EnergyProfileViewModel) { }

    func reapply(on model: EnergyProfileViewModel) { }

    func nextStateAutoDispatchDelay(model: EnergyProfileViewModel) -> Double? { nil }

    let delayedStates = [DelayedState<EnergyProfileState>]()
}

fileprivate class IntroState: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.intro)
    }

    override func apply(on model: EnergyProfileViewModel) {
        model.resetState()
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
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
        model.highlightedElements = [.rateRatioEquation]
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.highlightedElements = []
    }
}

fileprivate class ShowUpdatedEaValues: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [SpeechBubbleLine] {
        EnergyProfileStatements.showEaReduction(newEa: model.activationEnergy)
    }

    override func apply(on model: EnergyProfileViewModel) {
        model.highlightedElements = [.reactionProfileTop, .reactionProfileBottom]
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.highlightedElements = []
    }
}

fileprivate class ShowLinearChart: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [SpeechBubbleLine] {
        EnergyProfileStatements.showLinearChart(slope: model.slope)
    }

    override func apply(on model: EnergyProfileViewModel) {
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
        model.highlightedElements = [.linearChart, .rateRatioEquation]
    }

    override func reapply(on model: EnergyProfileViewModel) {
        apply(on: model)
    }

    override func unapply(on model: EnergyProfileViewModel) {
        model.highlightedElements = []
    }
}

fileprivate class ReactionEndedState: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.finished)
    }

    override func apply(on model: EnergyProfileViewModel) {
        model.endReaction()
    }
}
