//
// Reactions App
//
  

import SwiftUI

class ZeroOrderBeakyViewModel: ObservableObject {

    @Published var statement: [SpeechBubbleLine] = []

    let reactionViewModel: ReactionViewModel

    private var applyNextStateDispatchId: UUID?

    init(reactionViewModel: ReactionViewModel) {
        self.currentIndex = 0
        self.reactionViewModel = reactionViewModel
        setStatement()
        if let state = getState(for: currentIndex) {
            state.apply(on: reactionViewModel)
        }
    }

    private let states: [ReactionState] = [
        InitialStep(),
        SetFinalValuesToNonNil(),
        RunAnimation(),
        EndStatement(),
    ]

    private var currentIndex: Int {
        didSet {
            setStatement()
        }
    }

    func next() {
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
        applyNextStateDispatchId = nil
        if let delay = state.nextStateAutoDispatchDelay(model: reactionViewModel) {
            let lock = UUID()
            applyNextStateDispatchId = lock
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.nextWithLock(lock: lock)
            }
        }
    }

    private func nextWithLock(lock: UUID) {
        if let currentLock = applyNextStateDispatchId, currentLock == lock {
            next()
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
    func nextStateAutoDispatchDelay(model: ReactionViewModel) -> DispatchTimeInterval?
}

extension ReactionState {
    func nextStateAutoDispatchDelay(model: ReactionViewModel) -> DispatchTimeInterval? {
        return nil
    }
}

fileprivate struct InitialStep: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderBeakyStatements.statement1

    func apply(on model: ReactionViewModel) { }

    func unapply(on model: ReactionViewModel) { }

    func reapply(on model: ReactionViewModel) { }
}



fileprivate struct SetFinalValuesToNonNil: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderBeakyStatements.statement2

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

    var statement: [SpeechBubbleLine] = ZeroOrderBeakyStatements.statment3

    func apply(on model: ReactionViewModel) {
        if let finalTime = model.finalTime, let halfTime = model.halfTime {
            model.currentTime = model.initialTime
            withAnimation(.linear(duration: Double(2 * halfTime))) {
                model.currentTime = finalTime
            }
        }
    }

    func reapply(on model: ReactionViewModel) {
        apply(on: model)
    }

    func unapply(on model: ReactionViewModel) {
        withAnimation(.none) {
            model.currentTime = nil
        }
    }

    func nextStateAutoDispatchDelay(model: ReactionViewModel) -> DispatchTimeInterval? {
        if let halfTime = model.halfTime {
            return .milliseconds( Int(halfTime * 2000))
        }
        return nil
    }

    var userCanApplyNext: Bool { true }
}

fileprivate struct EndStatement: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderBeakyStatements.endStatement

    func apply(on model: ReactionViewModel) {
        withAnimation(.easeOut(duration: 0.5)) {
            if let finalTime = model.finalTime {
                model.currentTime = finalTime * 1.001
            }
        }
    }

    func unapply(on model: ReactionViewModel) { }

    func reapply(on model: ReactionViewModel) { }
}

struct ZeroOrderBeakyStatements {

    static let statement1: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(
            str: "This is a zero Order Reaction."
        ),
        SpeechBubbleLineGenerator.makeLine(
            str: "Why don't you set the *initial time (t1)* and *initial concentration of A (c1)*, the reactant?"
        )
    ]

    static let statement2: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(
            str: "Great! Now you can set the *concentration of A at the end of the reaction (c2)* and the *time the reaction will last (t2)*"
        )
    ]

    static let statment3: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(
            str: "Let's watch all the molecules changing"
        ),
        SpeechBubbleLineGenerator.makeLine(
            str: "As A disappears, B is being produced."
        )
    ]

    static var statement4: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(str: "Half way through!")
    ]

    static var endStatement: [SpeechBubbleLine] = [
        SpeechBubbleLineGenerator.makeLine(str: "Amazing!")
    ]
}
