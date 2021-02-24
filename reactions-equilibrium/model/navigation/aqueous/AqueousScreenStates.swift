//
// Reactions App
//

import ReactionsCore
import SwiftUI

class AqueousScreenState: ScreenState, SubState {

    typealias Model = AqueousReactionViewModel
    typealias NestedState = AqueousScreenState

    var delayedStates = [DelayedState<AqueousScreenState>]()

    func apply(on model: AqueousReactionViewModel) { }

    func unapply(on model: AqueousReactionViewModel) { }

    func reapply(on model: AqueousReactionViewModel) {
        apply(on: model)
    }

    func nextStateAutoDispatchDelay(model: AqueousReactionViewModel) -> Double? {
        nil
    }
}

class AqueousIntroState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.canSetLiquidLevel = true
        model.canAddReactants = false
        model.moleculesA.removeAll()
        model.moleculesB.removeAll()
    }
}

class AqueousAddReactantState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.canAddReactants = true
        model.canSetLiquidLevel = false
    }
}

class AqueousRunAnimationState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        let time = AqueousReactionSettings.totalReactionTime
        model.currentTime = 0
        model.canAddReactants = false
        withAnimation(.linear(duration: Double(time))) {
            model.currentTime = time
        }
    }

    override func unapply(on model: AqueousReactionViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
        }
        model.reactionState = .notStarted
    }
}

class AqueousEndAnimationState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = AqueousReactionSettings.totalReactionTime * 1.0001
        }
        model.canSetCurrentTime = true
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.canSetCurrentTime = false
    }
}
