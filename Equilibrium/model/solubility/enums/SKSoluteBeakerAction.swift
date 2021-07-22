//
// Reactions App
//

import Foundation

enum SKSoluteBeakerAction: Equatable {
    case none,
         runReaction,
         completeReaction,
         undoReaction,
         cleanupDemoReaction,
         removeSolute(duration: TimeInterval),
         hideSolute(duration: TimeInterval),
         reAddSolute(duration: TimeInterval)
}

