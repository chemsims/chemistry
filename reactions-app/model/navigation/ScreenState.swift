//
// Reactions App
//
  

import Foundation

protocol ScreenState {
    associatedtype Model
    associatedtype NestedState: SubState where NestedState.Model == Model

    /// Optionally provide delayed states which will be automatically applied. Each delay is relative to the previous state,
    /// as opposed to an absolute delay.
    ///
    /// The difference between a delayed state and `nextStateAutoDispatchDelay` is that the
    /// latter is a state which can be navigated to/from by the user, whereas a substate will only be applied
    /// while the parent state is still selected.
    ///
    /// Note that if `nextStateAutoDispatchDelays` is set, it's value is respected and any
    /// delayed states which have yet to be run will be ignored.
    var delayedStates: [DelayedState<NestedState>] { get }

    /// Applies the reaction state to the model
    func apply(on model: Model) -> Void

    /// Unapplies the reaction state to the model. i.e., reversing the effect of `apply`
    func unapply(on model: Model) -> Void

    /// Reapplies the state, when returning from a subsequent state.
    func reapply(on model: Model) -> Void

    /// TimeInterval (i.e. time in seconds) to wait before automatically progressing to the next state
    func nextStateAutoDispatchDelay(model: Model) -> Double?

    /// When clicking back, should this state be ignored
    var ignoreOnBack: Bool { get }
}

extension ScreenState {
    var ignoreOnBack: Bool {
        false
    }
}

protocol SubState {
    associatedtype Model
    func apply(on model: Model)
}

struct DelayedState<State: SubState> {
    let state: State
    let delay: Double
}
