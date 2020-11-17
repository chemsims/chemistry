//
// Reactions App
//
  

import SwiftUI

class ZeroOrderUserFlowViewModel: ReactionUserFlowViewModel {
    init(reactionViewModel: ReactionViewModel) {
        super.init(
            reactionViewModel: reactionViewModel,
            states: [
                InitialStep(),
                SetFinalValuesToNonNil(),
                RunAnimation(),
                EndAnimation(),
            ]
        )
    }
}

class FirstOrderUserFlowViewModel: ReactionUserFlowViewModel {
    init(reactionViewModel: ReactionViewModel) {
        super.init(
            reactionViewModel: reactionViewModel,
            states: [
                InitialiseFirstOrder(),
                SetFinalConcentrationToNonNil(),
                RunAnimation(),
                EndAnimation()
            ]
        )
    }
}

class ReactionUserFlowViewModel: ObservableObject {

    @Published var statement: [SpeechBubbleLine] = []

    let reactionViewModel: ReactionViewModel

    private var nextTimer: Timer?

    init(reactionViewModel: ReactionViewModel, states: [ReactionState]) {
        self.states = states
        self.currentIndex = 0
        self.reactionViewModel = reactionViewModel
        setStatement()
        if let state = getState(for: currentIndex) {
            state.apply(on: reactionViewModel)
        }
    }

    private let states: [ReactionState]
    private var currentIndex: Int {
        didSet {
            setStatement()
        }
    }

    @objc func next() {
        let nextIndex = currentIndex + 1
        if let state = getState(for: nextIndex) {
            state.apply(on: reactionViewModel)
            currentIndex = nextIndex
            scheduleNextState(for: state)
        }
    }

    func back() {
        let previousIndex = currentIndex - 1
        if let currentState = getState(for: currentIndex),
           let previousState = getState(for: previousIndex) {
            currentState.unapply(on: reactionViewModel)
            previousState.reapply(on: reactionViewModel)
            currentIndex = previousIndex
            scheduleNextState(for: previousState)
        }
    }

    private func scheduleNextState(for state: ReactionState) {
        if let timer = nextTimer {
            timer.invalidate()
            nextTimer = nil
        }
        if let delay = state.nextStateAutoDispatchDelay(model: reactionViewModel) {
            nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(next), userInfo: nil, repeats: false)
        }
    }

    private func setStatement() {
        let state = getState(for: currentIndex)
        statement = state?.statement ?? []
    }

    private func getState(for n: Int) -> ReactionState? {
        states.indices.contains(n) ? states[n] : nil
    }
}

protocol ReactionState {

    /// The statement to display to the user
    var statement: [SpeechBubbleLine] { get }

    /// Applies the reaction state to the model
    func apply(on model: ReactionViewModel) -> Void

    /// Unapplies the reaction state to the model. i.e., reversing the effect of `apply`
    func unapply(on model: ReactionViewModel) -> Void

    /// Reapplies the state, when returning from a subsequent state.
    func reapply(on model: ReactionViewModel) -> Void

    /// Interval to wait before automatically progressing to the next state
    func nextStateAutoDispatchDelay(model: ReactionViewModel) -> Double?
}

extension ReactionState {
    func nextStateAutoDispatchDelay(model: ReactionViewModel) -> Double? {
        return nil
    }
}

fileprivate struct InitialStep: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderStatements.initial

    func apply(on model: ReactionViewModel) { }

    func unapply(on model: ReactionViewModel) { }

    func reapply(on model: ReactionViewModel) { }
}

fileprivate struct InitialiseFirstOrder: ReactionState {

    var statement: [SpeechBubbleLine] = FirstOrderStatements.intro


    func apply(on model: ReactionViewModel) {
        model.initialTime = 0
        model.finalTime = 10
    }

    func unapply(on model: ReactionViewModel) {

    }

    func reapply(on model: ReactionViewModel) {

    }
}

fileprivate struct SetFinalConcentrationToNonNil: ReactionState {

    var statement: [SpeechBubbleLine] = FirstOrderStatements.setC2

    func apply(on model: ReactionViewModel) {
        model.finalConcentration = model.initialConcentration / 2
    }

    func unapply(on model: ReactionViewModel) {
        model.finalConcentration = nil
    }

    func reapply(on model: ReactionViewModel) {

    }
}


fileprivate struct SetFinalValuesToNonNil: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderStatements.setFinalValues

    func apply(on model: ReactionViewModel) {
        let initialConcentration = model.initialConcentration
        let minConcentration = ReactionSettings.minConcentration

        let initialTime = model.initialTime
        let maxTime = ReactionSettings.maxTime

        model.finalConcentration = (initialConcentration + minConcentration) / 2
        model.finalTime = (initialTime + maxTime) / 2
    }

    func reapply(on model: ReactionViewModel) { }

    func unapply(on model: ReactionViewModel) {
        model.finalConcentration = nil
        model.finalTime = nil
    }
}

fileprivate struct RunAnimation: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderStatements.inProgress

    func apply(on model: ReactionViewModel) {
        model.reactionHasEnded = false
        if let duration = model.reactionDuration, let finalTime = model.finalTime {
            model.currentTime = model.initialTime
            model.moleculeBOpacity = 0
            model.timeChartHeadOpacity = 1
            print("Running for \(duration)")
            withAnimation(.linear(duration: Double(duration))) {
                model.currentTime = finalTime
                model.moleculeBOpacity = 1
            }
        }
    }

    func reapply(on model: ReactionViewModel) {
        apply(on: model)
    }

    func unapply(on model: ReactionViewModel) {
        withAnimation(.none) {
            model.currentTime = nil
            model.moleculeBOpacity = 0
        }
    }

    func nextStateAutoDispatchDelay(model: ReactionViewModel) -> Double? {
        if let duration = model.reactionDuration {
            return Double(duration)
        }
        return nil
    }

}

fileprivate struct EndAnimation: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderStatements.endStatement

    func apply(on model: ReactionViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            if let finalTime = model.finalTime {
                model.currentTime = finalTime * 1.001
                model.moleculeBOpacity = 1.001
            }
            model.reactionHasEnded = true
            model.timeChartHeadOpacity = 0
        }
    }

    func unapply(on model: ReactionViewModel) {
        model.timeChartHeadOpacity = 1
    }

    func reapply(on model: ReactionViewModel) { }
}

