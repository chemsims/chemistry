//
// Reactions App
//
  

import SwiftUI

class ZeroOrderBeakyViewModel: ObservableObject {

    @Published var statement: [SpeechBubbleLine] = []

    let reactionViewModel: ReactionViewModel

    private var autoDispatchLock: UUID?

    init(reactionViewModel: ReactionViewModel) {
        self.currentStep = 0
        self.reactionViewModel = reactionViewModel
        setStatement()
        if let step = getStep(for: currentStep) {
            step.apply(on: reactionViewModel)
        }
    }

    private let steps: [ReactionState] = [
        InitialStep(),
        SetFinalValuesToNonNil(),
        RunAnimation(),
        EndStatement(),
    ]

    private var currentStep: Int {
        didSet {
            setStatement()
        }
    }

    func next() {
        if let step = getStep(for: currentStep + 1) {
            apply(state: step, step: currentStep + 1)
        }
    }

    func back() {
        if let step = getStep(for: currentStep),
           let previousStep = getStep(for: currentStep - 1) {
            step.unapply(on: reactionViewModel)
            apply(state: previousStep, step: currentStep - 1)
        }
    }

    private func apply(state: ReactionState, step: Int) {
        autoDispatchLock = nil
        state.apply(on: reactionViewModel)
        currentStep = step
        scheduleNextState(with: state)
    }

    private func scheduleNextState(with state: ReactionState) {
        if let delay = state.nextStateAutoDispatchDelay(model: reactionViewModel) {
            let lock = UUID()
            autoDispatchLock = lock
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.nextWithLock(lock: lock)
            }
        }
    }

    private func nextWithLock(lock: UUID) {
        if let currentLock = autoDispatchLock, currentLock == lock {
            next()
        }
    }

    private func setStatement() {
        let step = getStep(for: currentStep)
        statement = step?.statement ?? []
    }

    private func getStep(for n: Int) -> ReactionState? {
        steps.indices.contains(n) ? steps[n] : nil
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
            withAnimation(.linear(duration: Double(2))) {
                model.currentTime = finalTime
            }
        }
    }

    func reapply(on model: ReactionViewModel) {
        apply(on: model)
    }

    func unapply(on model: ReactionViewModel) {
        model.currentTime = nil
    }

    func nextStateAutoDispatchDelay(model: ReactionViewModel) -> DispatchTimeInterval? {
        if let halfTime = model.halfTime {
            let milliseconds = Int(2 * 1000)
            return .milliseconds(milliseconds)
        }
        return nil
    }

    var userCanApplyNext: Bool { true }
}

fileprivate struct EndStatement: ReactionState {

    var statement: [SpeechBubbleLine] = ZeroOrderBeakyStatements.endStatement

    func apply(on model: ReactionViewModel) {
        withAnimation(.easeOut(duration: 1)) {
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
