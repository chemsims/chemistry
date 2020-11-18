//
// Reactions App
//
  

import SwiftUI

class ReactionNavigationViewModel: ObservableObject {

    @Published var statement: [SpeechBubbleLine] = []

    let reactionViewModel: ZeroOrderReactionViewModel

    private var nextTimer: Timer?

    init(reactionViewModel: ZeroOrderReactionViewModel, states: [ReactionState]) {
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
