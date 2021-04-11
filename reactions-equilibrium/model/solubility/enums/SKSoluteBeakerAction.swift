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
         removeSolute,
         hideSolute(duration: TimeInterval),
         reAddSolute(duration: TimeInterval)
}

