//
// Reactions App
//


import Foundation
import CoreGraphics
import ReactionsCore

class PrecipitationComponents {
    struct Reaction {
        let unknownReactantCoeff: Int
        let unknownReactantMolarMass: Int
        let productMolarMass: Int
    }
}

extension PrecipitationComponents {
    struct Settings {
        init(
            minConcentrationOfKnownReactantPostFirstReaction: CGFloat = 0.15,
            minConcentrationOfUnknownReactantToReact: CGFloat = 0.15
        ) {
            self.minConcentrationOfKnownReactantPostFirstReaction = minConcentrationOfKnownReactantPostFirstReaction
            self.minConcentrationOfUnknownReactantToReact = minConcentrationOfUnknownReactantToReact
        }
        let minConcentrationOfKnownReactantPostFirstReaction: CGFloat
        let minConcentrationOfUnknownReactantToReact: CGFloat
    }
}

enum PrecipitationReactantType {
    case known,
         unknown
}

extension PrecipitationComponents {

    class KnownReactantPreparation {

        init(
            unknownReactantCoeff: Int,
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings
        ) {
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
            self.underlying = .init(
                grid: grid,
                minToAdd: minToAdd,
                maxToAdd: maxToAdd
            )
        }
        private(set) var underlying: LimitedGridCoords

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

    class UnknownReactantPreparation {
        static func minToAdd(
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings
        ) -> Int {
            grid.count(concentration: settings.minConcentrationOfUnknownReactantToReact)
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
