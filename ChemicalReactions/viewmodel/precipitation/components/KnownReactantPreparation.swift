//
// Reactions App
//

import ReactionsCore
import Foundation

extension PrecipitationComponents {
    struct KnownReactantPreparation {
        static func components(
            unknownReactantCoeff: Int,
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings,
            reactionProgressModel: ReactionProgressChartViewModel<PrecipitationComponents.Molecule>,
            precipitate: GrowingPolygon
        ) -> ReactantPreparation {
            let minToAdd = Self.minToAdd(
                unknownReactantCoeff: unknownReactantCoeff,
                grid: grid,
                settings: settings
            )
            let maxToAdd = Self.maxToAdd(
                unknownReactantCoeff: unknownReactantCoeff,
                grid: grid,
                settings: settings
            )
            return ReactantPreparation(
                grid: grid,
                reactant: .known,
                minToAdd: minToAdd,
                maxToAdd: maxToAdd,
                reactionProgressModel: reactionProgressModel,
                previous: nil,
                precipitate: precipitate
            )
        }

        static func minToAdd(
            unknownReactantCoeff: Int,
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings
        ) -> Int {
            let minToRemain = grid.count(
                concentration: settings.minConcentrationOfKnownReactantPostFirstReaction
            )
            let minConsumedOtherReactant = grid.count(
                concentration: settings.minConcentrationOfUnknownReactantToReact
            )
            let minConsumed = minConsumedOtherReactant / unknownReactantCoeff
            return minToRemain + minConsumed
        }

        /// Returns max known coords, such that they can all be consumed by adding enough
        /// unknown reactant later.
        static func maxToAdd(
            unknownReactantCoeff: Int,
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings
        ) -> Int {
            let maxToRemain = grid.size / (1 + unknownReactantCoeff)
            let availableForReaction = grid.size - maxToRemain
            let consumed = availableForReaction / (1 + unknownReactantCoeff)
            return maxToRemain + consumed
        }
    }
}
