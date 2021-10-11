//
// Reactions App
//

import ReactionsCore
import Foundation

extension PrecipitationComponents {
    struct UnknownReactantPreparation: PrecipitationComponentsReactantPreparation {

        init(
            unknownReactantCoeff: Int,
            previous: KnownReactantPreparation,
            grid: BeakerGrid,
            settings: Settings
        ) {
            let knownReactantCoords = previous.initialCoords(for: .knownReactant)
            let (min, max) = Self.inputLimits(
                unknownReactantCoeff: unknownReactantCoeff,
                knownReactantCount: knownReactantCoords.count,
                grid: grid,
                settings: settings
            )
            self.previous = previous
            self.reactionProgressModel = previous.reactionProgressModel.copy()
            self.settings = settings
            self.underlying = LimitedGridCoords(
                grid: grid,
                initialCoords: [],
                otherCoords: knownReactantCoords,
                minToAdd: min,
                maxToAdd: max
            )
        }

        let reactionProgressModel: ReactionProgressModel
        let settings: Settings
        private var underlying: LimitedGridCoords
        private let previous: KnownReactantPreparation

        func initialCoords(for molecule: PrecipitationComponents.Molecule) -> [GridCoordinate] {
            if molecule == .unknownReactant {
                return underlying.coords
            }
            return previous.initialCoords(for: molecule)
        }

        mutating func add(reactant: Reactant, count: Int) {
            guard canAdd(reactant: reactant) else {
                return
            }
            underlying.add(count: count)
            reactionProgressModel.addMolecules(
                .unknownReactant,
                concentration: underlying.concentration,
                duration: settings.addMoleculeReactionProgressDuration
            )
        }

        func canAdd(reactant: Reactant) -> Bool {
            reactant == .unknown && underlying.canAdd
        }

        func hasAddedEnough(of reactant: Reactant) -> Bool {
            reactant != .unknown || underlying.hasAddedEnough
        }
    }
}

extension PrecipitationComponents.UnknownReactantPreparation {
    static func inputLimits(
        unknownReactantCoeff: Int,
        knownReactantCount: Int,
        grid: BeakerGrid,
        settings: PrecipitationComponents.Settings
    ) -> (min: Int, max: Int) {

        let model = UnknownReactantPrepInputLimits(
            unknownReactantCoeff: unknownReactantCoeff,
            knownReactantCount: knownReactantCount,
            grid: grid,
            settings: settings
        )

        return (min: model.min, max: model.max)
    }
}
