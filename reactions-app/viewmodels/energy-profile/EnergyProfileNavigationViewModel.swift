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
        IntroState(),
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
            []
        ),
        ExplanationState(
            EnergyProfileStatements.explainArrhenius,
            []
        ),
        ExplanationState(
            EnergyProfileStatements.explainTerms,
            []
        ),
        ExplanationState(
            EnergyProfileStatements.explainRateTempRelation,
            []
        ),
        ExplanationState(
            EnergyProfileStatements.explainLinearKEquation,
            []
        ),
        ExplanationState(
            EnergyProfileStatements.explainArrheniusTwoPoints,
            []
        ),
        ShowInitialEaValues(),
        ExplanationState(
            EnergyProfileStatements.explainEnergyDiagram,
            []
        ),
        ExplanationState(
            EnergyProfileStatements.explainExothermic,
            []
        ),
        ExplanationState(
            EnergyProfileStatements.explainEaHump,
            []
        ),
        ExplanationState(
            EnergyProfileStatements.explainCatalyst,
            []
        ),
        ExplanationState(
            EnergyProfileStatements.instructToChooseCatalyst,
            []
        ),
        ExplanationState(
            EnergyProfileStatements.instructToShakeCatalyst,
            []
        ),
        ShowUpdatedEaValues(),
        ShowLinearChart(),
        ShowKRatio(),
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
        _ highlight: [OrderedReactionScreenHighlightingElements]
    ) {
        super.init(statement: statement)
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
}

fileprivate class ShowUpdatedEaValues: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [SpeechBubbleLine] {
        EnergyProfileStatements.showEaReduction(newEa: model.activationEnergy)
    }
}

fileprivate class ShowLinearChart: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [SpeechBubbleLine] {
        EnergyProfileStatements.showLinearChart(slope: model.slope)
    }
}

fileprivate class ShowKRatio: EnergyProfileState {
    override func statement(model: EnergyProfileViewModel) -> [SpeechBubbleLine] {
        EnergyProfileStatements.showKRatio(newK: model.k2 ?? 0)
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
