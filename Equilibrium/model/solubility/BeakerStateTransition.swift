//
// Reactions App
//

import Foundation

struct BeakerStateTransition: Equatable {
    private(set) var state: BeakerState
    private(set) var actions: [SKSoluteBeakerAction]

    init() {
        self.init(state: .none, actions: [])
    }

    private init(state: BeakerState, actions: [SKSoluteBeakerAction]) {
        self.state = state
        self.actions = actions
    }

    mutating func goTo(
        state: BeakerState,
        with action: SKSoluteBeakerAction
    ) {
        self.goTo(state: state, with: [action])
    }

    mutating func goTo(
        state: BeakerState,
        with actions: [SKSoluteBeakerAction]
    ) {
        self.state = state
        self.actions = actions
    }

}
