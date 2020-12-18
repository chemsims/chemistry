//
// Reactions App
//
  

import SwiftUI

struct EnergyProfileNavigationViewModel {
    static func model(_ energyViewModel: EnergyProfileViewModel) -> NavigationViewModel<EnergyProfileState> {
        NavigationViewModel(
            reactionViewModel: energyViewModel,
            states: [
                IntroState(),
                ReactionEndedState()
            ]
        )
    }
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

fileprivate class ReactionEndedState: EnergyProfileState {
    init() {
        super.init(statement: EnergyProfileStatements.finished)
    }

    override func apply(on model: EnergyProfileViewModel) {
        model.endReaction()
    }
}
