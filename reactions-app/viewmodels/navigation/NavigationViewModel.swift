//
// Reactions App
//
  

import SwiftUI

class NavigationViewModel<State: ScreenState>: ObservableObject {

    var nextScreen: (() -> Void)?
    var prevScreen: (() -> Void)?

    let model: State.Model
    private let states: [State]

    private var nextTimer: Timer?
    private var subTimer: Timer?

    init(reactionViewModel: State.Model, states: [State]) {
        self.states = states
        self.currentIndex = 0
        self.model = reactionViewModel
        if let state = getState(for: currentIndex) {
            state.apply(on: reactionViewModel)
        }
    }

    private var currentIndex: Int

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
            if (!currentState.ignoreOnBack) {
                currentState.unapply(on: model)
            }
            currentIndex = previousIndex
            if (previousState.ignoreOnBack) {
                back()
            } else {
                previousState.reapply(on: model)
                scheduleSubState(indexToRun: 0)
                scheduleNextState(for: previousState)
            }
        } else if let prevScreen = prevScreen {
            prevScreen()
        }
    }

    private func scheduleSubState(indexToRun: Int) {
        if let timer = subTimer {
            timer.invalidate()
            nextTimer = nil
        }
        guard let state = getState(for: currentIndex),
              state.delayedStates.count > indexToRun else {
            return
        }

        let next = state.delayedStates[indexToRun]
        subTimer = Timer.scheduledTimer(timeInterval: next.delay, target: self, selector: #selector(runForIndex), userInfo: indexToRun, repeats: false)
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
        if let timer = nextTimer {
            timer.invalidate()
            nextTimer = nil
        }
        if let delay = state.nextStateAutoDispatchDelay(model: model) {
            nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(next), userInfo: nil, repeats: false)
        }
    }

    private func getState(for n: Int) -> State? {
        states.indices.contains(n) ? states[n] : nil
    }
}
