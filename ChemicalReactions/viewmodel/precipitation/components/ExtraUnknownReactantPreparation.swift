//
// Reactions App
//

import CoreGraphics
import ReactionsCore

extension PrecipitationComponents {
    struct ExtraUnknownReactantPreparation: PrecipitationComponentsReactantPreparation {

        init(
            previous: InitialReaction,
            unknownReactantCoeff: Int,
            grid: BeakerGrid,
            settings: Settings
        ) {
            self.previous = previous
            self.reactionProgressModel = previous.reactionProgressModel.copy()
            self.precipitate = previous.precipitate
            self.settings = settings

            let productCoords = previous.finalCoords(for: .product)
            let knownCoords = previous.finalCoords(for: .knownReactant)

            let unknownRequiredToConsumeAllOfKnown = unknownReactantCoeff * knownCoords.count
            let knownRPMolecules = reactionProgressModel.moleculeCounts(ofType: .knownReactant)
            let unknownRPMoleculesRequired = unknownReactantCoeff * knownRPMolecules

            self.underlying = LimitedGridCoords(
                grid: grid,
                initialCoords: [],
                otherCoords: knownCoords + productCoords,
                minToAdd: unknownRequiredToConsumeAllOfKnown,
                maxToAdd: unknownRequiredToConsumeAllOfKnown
            )
            self.reactionProgressCoordCount = LinearEquation(
                x1: 0,
                y1: 0,
                x2: CGFloat(unknownRequiredToConsumeAllOfKnown),
                y2: CGFloat(unknownRPMoleculesRequired)
            )
        }

        let reactionProgressModel: ReactionProgressModel
        var precipitate: GrowingPolygon
        let settings: Settings
        private let previous: InitialReaction
        private var underlying: LimitedGridCoords

        func initialCoords(for molecule: Molecule) -> [GridCoordinate] {
            if molecule == .unknownReactant {
                return underlying.coords
            }
            return previous.finalCoords(for: molecule)
        }

        mutating func add(reactant: Reactant, count: Int) {
            guard canAdd(reactant: reactant) else {
                return
            }
            underlying.add(count: count)

            let currentRPCount = reactionProgressModel.moleculeCounts(ofType: .unknownReactant)
            let desiredRPCount = reactionProgressCoordCount.getY(
                at: CGFloat(underlying.coords.count)
            ).roundedInt()

            let deficit = desiredRPCount - currentRPCount
            if deficit > 0 {
                reactionProgressModel.addMolecules(
                    .unknownReactant,
                    count: deficit,
                    duration: settings.addMoleculeReactionProgressDuration
                )
            }
        }

        func canAdd(reactant: Reactant) -> Bool {
            reactant == .unknown && underlying.canAdd
        }

        func hasAddedEnough(of reactant: Reactant) -> Bool {
            reactant != .unknown || underlying.hasAddedEnough || underlying.isOutOfSpace
        }

        private let reactionProgressCoordCount: Equation
    }
}
