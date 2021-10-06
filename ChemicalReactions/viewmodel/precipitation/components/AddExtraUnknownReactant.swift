//
// Reactions App
//

import CoreGraphics
import ReactionsCore

extension PrecipitationComponents {
    struct AddExtraUnknownReactant {
        static func components(
            previous: PhaseComponents,
            previouslyReactingUnknownReactantMoles: CGFloat,
            unknownReactantCoeff: Int,
            grid: BeakerGrid
        ) -> ReactantPreparation {
            let knownCoords = previous.coords(for: .knownReactant).coords(at: previous.endOfReaction).count
            let unknownRequiredToConsumeAllOfKnown = unknownReactantCoeff * knownCoords

            return ReactantPreparation(
                grid: grid,
                reactant: .unknown,
                minToAdd: unknownRequiredToConsumeAllOfKnown,
                maxToAdd: unknownRequiredToConsumeAllOfKnown,
                previous: previous,
                previouslyReactingUnknownReactantMoles: previouslyReactingUnknownReactantMoles
            )
        }
    }
}
