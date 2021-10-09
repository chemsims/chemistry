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
            reactionProgressModel: ReactionProgressModel,
            precipitate: GrowingPolygon,
            settings: PrecipitationComponents.Settings
        ) {
            self.unknownReactantCoeff = unknownReactantCoeff
            self.grid = grid
            self.settings = settings
            self.reactionProgressModel = reactionProgressModel
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

        let reactionProgressModel: ReactionProgressModel
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
            reactionProgressModel.addMolecules(
                .knownReactant,
                concentration: underlying.concentration,
                duration: settings.addMoleculeReactionProgressDuration
            )
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

    static func inputLimits(
        unknownReactantCoeff: Int,
        grid: BeakerGrid,
        settings: PrecipitationComponents.Settings
    ) -> (min: Int, max: Int) {
        let model = KnownReactantPrepInputLimits(
            unknownReactantCoeff: unknownReactantCoeff,
            grid: grid,
            settings: settings
        )

        return (min: model.min, max: model.max)
    }
}

