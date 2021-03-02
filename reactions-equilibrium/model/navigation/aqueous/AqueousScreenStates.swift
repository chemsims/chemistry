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
        let time = AqueousReactionSettings.forwardReactionTime
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
        Double(AqueousReactionSettings.forwardReactionTime)
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

    let statement: [TextLine]
    let endTime: CGFloat

    init(statement: [TextLine], endTime: CGFloat) {
        self.statement = statement
        self.endTime = endTime
    }

    override func apply(on model: AqueousReactionViewModel) {
        model.statement = statement
        withAnimation(.easeOut(duration: 0.5)) {
            model.currentTime = endTime * 1.0001
        }
        model.canSetCurrentTime = true
    }

    override func unapply(on model: AqueousReactionViewModel) {
        model.canSetCurrentTime = false
    }
}

class AqueousShiftChartState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.introToReverse
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = AqueousReactionSettings.forwardReactionTime
            model.currentTime = AqueousReactionSettings.timeToAddProduct
        }
    }

    override func unapply(on model: AqueousReactionViewModel) {
        withAnimation(.easeOut(duration: 1)) {
            model.chartOffset = 0
            model.currentTime = AqueousReactionSettings.forwardReactionTime
        }
    }
}

class InstructToAddProductState: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.instructToAddProduct(selected: model.selectedReaction)
        if let fwd = model.components as? ForwardAqueousReactionComponents {
            model.components = ReverseAqueousReactionComponents(forwardReaction: fwd)
        }
    }

    override func unapply(on model: AqueousReactionViewModel) {
        if let rev = model.components as? ReverseAqueousReactionComponents {
            model.components = rev.forwardReaction
        }
    }
}

class AqueousPreReverseAnimation: AqueousScreenState {
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.preReverseReaction
        model.inputState = .none
    }
}

class AqueousRunReverseAnimation: AqueousScreenState {

    private let tAddProduct = AqueousReactionSettings.timeToAddProduct
    private let tConvergence = AqueousReactionSettings.timeForReverseConvergence
    private let tEnd = AqueousReactionSettings.endOfReverseReaction
    
    override func apply(on model: AqueousReactionViewModel) {
        model.statement = AqueousStatements.reverseReactionStarted
        withAnimation(.linear(duration: Double(tEnd - tAddProduct))) {
            model.currentTime = tEnd
        }
    }

    override func reapply(on model: AqueousReactionViewModel) {
        model.currentTime = tAddProduct
        super.reapply(on: model)
    }

    override func unapply(on model: AqueousReactionViewModel) {
        withAnimation(.easeOut(duration: Double(0.5))) {
            model.currentTime = tAddProduct
        }
    }

    override var delayedStates: [DelayedState<AqueousScreenState>] {
        let tToConvergence = tConvergence - tAddProduct
        let delay = Double(tToConvergence / 2)
        return [
            DelayedState(
                state: AqueousSetStatementState(
                    statement: AqueousStatements.midReverseReaction
                ),
                delay: delay
            ),
            DelayedState(
                state: AqueousSetStatementState(
                    statement: AqueousStatements.reverseEquilibriumReached
                ),
                delay: delay
            )
        ]
    }

    override func nextStateAutoDispatchDelay(model: AqueousReactionViewModel) -> Double? {
        Double(AqueousReactionSettings.endOfReverseReaction - AqueousReactionSettings.timeToAddProduct)
    }
}
