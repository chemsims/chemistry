//
// Reactions App
//

import ReactionsCore
import Foundation

extension PrecipitationComponents {
    struct UnknownReactantPreparation {
        static func components(
            unknownReactantCoeff: Int,
            previous: PhaseComponents,
            grid: BeakerGrid,
            settings: Settings
        ) -> ReactantPreparation {
            let minToAdd = Self.minToAdd(
                grid: grid,
                settings: settings
            )
            let maxToAdd = Self.maxToAdd(
                unknownReactantCoeff: unknownReactantCoeff,
                knownReactantCount: previous.coords(for: .knownReactant).coordinates.count,
                grid: grid,
                settings: settings
            )
            return ReactantPreparation(
                grid: grid,
                reactant: .unknown,
                minToAdd: minToAdd,
                maxToAdd: maxToAdd,
                previous: previous
            )
        }

        static func minToAdd(
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings
        ) -> Int {
            grid.count(
                concentration: settings.minConcentrationOfUnknownReactantToReact
            )
        }

        static func maxToAdd(
            unknownReactantCoeff: Int,
            knownReactantCount: Int,
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings
        ) -> Int {
            let minKnownReactant = grid.count(
                concentration: settings.minConcentrationOfKnownReactantPostFirstReaction
            )
            let maxKnownReactantToConsume = knownReactantCount - minKnownReactant
            return maxKnownReactantToConsume * unknownReactantCoeff
        }
    }
}
