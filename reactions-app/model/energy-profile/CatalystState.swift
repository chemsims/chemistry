//
// Reactions App
//

import Foundation

enum CatalystState: Equatable {
    case disabled, visible, active
    case pending(catalyst: Catalyst)
    case selected(catalyst: Catalyst)
}

enum CatalystParticleState {
    case none, fallFromContainer, appearInBeaker
}
