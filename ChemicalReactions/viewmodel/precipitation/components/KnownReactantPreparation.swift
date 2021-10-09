//
// Reactions App
//

import ReactionsCore
import Foundation

extension PrecipitationComponents {
    struct KnownReactantPreparation: PrecipitationComponentsReactantPreparation {

        init(
            unknownReactantCoeff: Int,
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings,
            precipitate: GrowingPolygon
        ) {
            self.unknownReactantCoeff = unknownReactantCoeff
            self.grid = grid
            self.settings = settings
            self.precipitate = precipitate

            let (min, max) = Self.inputLimits(
                unknownReactantCoeff: unknownReactantCoeff,
                grid: grid,
                settings: settings
            )

            self.underlying = LimitedGridCoords(
                grid: grid,
                minToAdd: min,
                maxToAdd: max
            )
        }

        let unknownReactantCoeff: Int
        let grid: BeakerGrid
        let settings: PrecipitationComponents.Settings
        var precipitate: GrowingPolygon
        private var underlying: LimitedGridCoords

        func initialCoords(for molecule: PrecipitationComponents.Molecule) -> [GridCoordinate] {
            if molecule == .knownReactant {
                return underlying.coords
            }
            return []
        }

        mutating func add(reactant: PrecipitationComponents.Reactant, count: Int) {
            guard canAdd(reactant: reactant) else {
                return
            }
            underlying.add(count: count)
        }

        func canAdd(reactant: PrecipitationComponents.Reactant) -> Bool {
            reactant == .known && underlying.canAdd
        }

        func hasAddedEnough(of reactant: PrecipitationComponents.Reactant) -> Bool {
            reactant != .known || underlying.hasAddedEnough
        }
    }
}

extension PrecipitationComponents.KnownReactantPreparation {

    fileprivate static func inputLimits(
        unknownReactantCoeff: Int,
        grid: BeakerGrid,
        settings: PrecipitationComponents.Settings
    ) -> (min: Int, max: Int) {
        let min = minToAdd(
            unknownReactantCoeff: unknownReactantCoeff,
            grid: grid,
            settings: settings
        )
        let max = maxToAdd(
            unknownReactantCoeff: unknownReactantCoeff,
            grid: grid,
            settings: settings
        )

        return (min: min, max: max)
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
