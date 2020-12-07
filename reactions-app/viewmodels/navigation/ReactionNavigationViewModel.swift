//
// Reactions App
//
  

import SwiftUI

class ReactionNavigationViewModel<State: ScreenState>: ObservableObject {

    @Published var statement: [SpeechBubbleLine] = []

    var nextScreen: (() -> Void)?
    var prevScreen: (() -> Void)?

    let model: State.Model
    private let states: [State]

    private var nextTimer: Timer?

    init(reactionViewModel: State.Model, states: [State]) {
        self.states = states
        self.currentIndex = 0
        self.model = reactionViewModel
        setStatement()
        if let state = getState(for: currentIndex) {
            state.apply(on: reactionViewModel)
        }
    }

    private var currentIndex: Int {
        didSet {
            setStatement()
        }
    }

    @objc func next() {
        let nextIndex = currentIndex + 1
        if let state = getState(for: nextIndex) {
            state.apply(on: model)
            currentIndex = nextIndex
            scheduleSubState(indexToRun: 0)
            scheduleNextState(for: state)
        } else if let nextScreen = nextScreen {
            nextScreen()
        }
    }

    func back() {
        let previousIndex = currentIndex - 1
        if let currentState = getState(for: currentIndex),
           let previousState = getState(for: previousIndex) {
            currentState.unapply(on: model)
            previousState.reapply(on: model)
            currentIndex = previousIndex
            scheduleNextState(for: previousState)
            scheduleSubState(indexToRun: 0)
        } else if let prevScreen = prevScreen {
            prevScreen()
        }
    }

    private func scheduleSubState(indexToRun: Int) {
        if let timer = nextTimer {
            timer.invalidate()
            nextTimer = nil
        }
        guard let state = getState(for: currentIndex),
              state.delayedStates.count > indexToRun else {
            return
        }

        let next = state.delayedStates[indexToRun]
        nextTimer = Timer.scheduledTimer(timeInterval: next.delay, target: self, selector: #selector(runForIndex), userInfo: indexToRun, repeats: false)
    }

    @objc private func runForIndex(timer: Timer) {
        guard let state = getState(for: currentIndex),
              let index = timer.userInfo as? Int,
              state.delayedStates.count > index
        else {
            return
        } 
        state.delayedStates[index].state.apply(on: model)
        scheduleSubState(indexToRun: index + 1)
    }


    private func scheduleNextState(for state: State) {
        if let delay = state.nextStateAutoDispatchDelay(model: model) {
            if let timer = nextTimer {
                timer.invalidate()
                nextTimer = nil
            }
            nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(next), userInfo: nil, repeats: false)
        }
    }

    private func setStatement() {
        let state = getState(for: currentIndex)
        statement = state?.statement ?? []
    }

    private func getState(for n: Int) -> State? {
        states.indices.contains(n) ? states[n] : nil
    }
}
