//
// Reactions App
//

import ReactionsCore
import SwiftUI

class AqueousScreenState: ScreenState, SubState {

    typealias Model = AqueousReactionViewModel
    typealias NestedState = AqueousScreenState

    var delayedStates: [DelayedState<AqueousScreenState>] {
        []
    }

    func apply(on model: AqueousReactionViewModel) { }

    func unapply(on model: AqueousReactionViewModel) { }

    func reapply(on model: AqueousReactionViewModel) {
        apply(on: model)
    }

    func nextStateAutoDispatchDelay(model: AqueousReactionViewModel) -> Double? {
        nil
    }
}

class AqueousSetStatementState: AqueousScreenState {

    let statement: [TextLine]
    init(statement: [TextLine]) {
        self.statement = statement
    }

    override func apply(on model: AqueousReactionViewModel) {
        model.statement = statement
    }
}

class AqueousSetWaterLevelState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.inputState = .setLiquidLevel
        model.statement = AqueousStatements.instructToSetWaterLevel
    }

    override func reapply(on model: AqueousReactionViewModel) {
        model.resetMolecules()
        super.reapply(on: model)
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.inputState = .none
    }
}

class AqueousAddReactantState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.instructToAddReactant(selected: model.selectedReaction)
        model.inputState = .addReactants
        model.showConcentrationLines = true
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.showConcentrationLines = false
    }
}

class AqueousPreRunAnimationState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.preAnimation
        model.inputState = .none
        model.showQuotientLine = true
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.showQuotientLine = false
    }
}

class AqueousRunAnimationState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.runAnimation
        let time = AqueousReactionSettings.totalReactionTime
        model.currentTime = 0
        withAnimation(.linear(duration: Double(time))) {
            model.currentTime = time
        }
    }

    override func unapply(on model: AqueousReactionViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = 0
        }
    }

    override func nextStateAutoDispatchDelay(model: AqueousReactionViewModel) -> Double? {
        Double(AqueousReactionSettings.totalReactionTime)
    }

    override var delayedStates: [DelayedState<AqueousScreenState>] {
        func delayedState(_ statement: [TextLine], _ delay: Double) -> DelayedState<AqueousScreenState> {
            DelayedState(state: AqueousSetStatementState(statement: statement), delay: delay)
        }
        let delay = Double(AqueousReactionSettings.timeForConvergence / 2)
        return [
            delayedState(AqueousStatements.midAnimation, delay),
            delayedState(AqueousStatements.reachedEquilibrium, delay),
        ]
    }
}

class AqueousEndAnimationState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.reachedEquilibrium
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = AqueousReactionSettings.totalReactionTime * 1.0001
        }
        model.canSetCurrentTime = true
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.canSetCurrentTime = false
    }
}

class AqueousShiftChartState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = ["Moved the chart"]
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = AqueousReactionSettings.totalReactionTime
            model.currentTime = AqueousReactionSettings.timeToAddProduct
        }
        if let fwd = model.components as? ForwardAqueousReactionComponents {
            model.components = ReverseAqueousReactionComponents(forwardReaction: fwd)
        }
    }

    override func unapply(on model: AqueousReactionViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = 0
            model.currentTime = AqueousReactionSettings.totalReactionTime
        }
    }
}
