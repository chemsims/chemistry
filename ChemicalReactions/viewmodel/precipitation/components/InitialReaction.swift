//
// Reactions App
//

import ReactionsCore
import CoreGraphics

extension PrecipitationComponents {

    struct InitialReaction: PhaseComponents {

        init(
            unknownReactantCoeff: Int,
            previous: PhaseComponents,
            endOfReaction: CGFloat,
            grid: BeakerGrid
        ) {
            self.unknownReactantCoeff = unknownReactantCoeff
            self.underlyingPrevious = previous
            self.endOfReaction = endOfReaction
            self.grid = grid
            self.precipitate = previous.precipitate

            let unknownReactantCount = previous.coords(for: .unknownReactant).coordinates.count
            let knownReactantToConsume = CGFloat(unknownReactantCount) / CGFloat(unknownReactantCoeff)

            /// The coeff of both product and known reactant is always 1, so the amount of known
            /// reactant consumed is the same as product produced
            let productToAdd = knownReactantToConsume.roundedInt()

            let productCoords = GridCoordinateList.spiralGrid(
                cols: grid.cols,
                rows: grid.rows,
                count: productToAdd
            )

            let knownReactantCoords = previous.coords(for: .knownReactant).coordinates

            let productCoordsSet = Set(productCoords)

            // We'd like to first consume any known coords which intersect the product coords
            let knownCoordsIntersectingProduct = knownReactantCoords.filter {
                productCoordsSet.contains($0)
            }
            let otherKnownCoords = knownReactantCoords.filter {
                !productCoordsSet.contains($0)
            }


            self.knownReactantToConsume = knownReactantToConsume
            self.underlyingProductCoords = productCoords
            self.underlyingKnownCoords = otherKnownCoords + knownCoordsIntersectingProduct
            self.reactionProgressModel = previous.reactionProgressModel.copy()
        }

        var precipitate: GrowingPolygon

        let startOfReaction: CGFloat = 0
        let endOfReaction: CGFloat

        var previous: PhaseComponents? {
            underlyingPrevious
        }

        let unknownReactantCoeff: Int
        let underlyingPrevious: PhaseComponents
        let grid: BeakerGrid

        let previouslyReactingUnknownReactantMoles: CGFloat = 0

        let reactionProgressModel: ReactionProgressChartViewModel<PrecipitationComponents.Molecule>

        func coords(for molecule: PrecipitationComponents.Molecule) -> FractionedCoordinates {
            switch molecule {
            case .knownReactant: return knownReactantCoords
            case .unknownReactant: return unknownReactantCoords
            case .product: return productCoords
            }
        }

        private var knownReactantCoords: FractionedCoordinates {
            let initialCount = underlyingKnownCoords.count
            let finalCount = CGFloat(initialCount) - knownReactantToConsume
            let finalFraction = finalCount / CGFloat(initialCount)

            return FractionedCoordinates(
                coordinates: underlyingKnownCoords,
                fractionToDraw: LinearEquation(
                    x1: 0,
                    y1: 1,
                    x2: endOfReaction,
                    y2: finalFraction
                )
            )
        }

        private var unknownReactantCoords: FractionedCoordinates {
            FractionedCoordinates(
                coordinates: underlyingPrevious.coords(for: .unknownReactant).coordinates,
                fractionToDraw: LinearEquation(
                    x1: 0,
                    y1: 1,
                    x2: endOfReaction,
                    y2: 0
                )
            )
        }

        private var productCoords: FractionedCoordinates {
            FractionedCoordinates(
                coordinates: underlyingProductCoords,
                fractionToDraw: LinearEquation(
                    x1: 0,
                    y1: 0,
                    x2: endOfReaction,
                    y2: 1
                )
            )
        }

        private let knownReactantToConsume: CGFloat
        private let underlyingProductCoords: [GridCoordinate]
        private let underlyingKnownCoords: [GridCoordinate]

        var reactionsToRun: Int {
            let unknownMoleculeCount = reactionProgressModel.moleculeCounts(ofType: .unknownReactant)
            let multiples = unknownMoleculeCount / unknownReactantCoeff
            if unknownMoleculeCount % unknownReactantCoeff == 0 {
                return multiples
            }
            return multiples + 1
        }

        func runOneReactionProgressReaction() {
            reactionProgressModel.startReactionFromExisting(
                consuming: [
                    (.knownReactant, 1),
                    (.unknownReactant, unknownReactantCoeff)
                ],
                producing: [.product]
            )
        }

        func runAllReactionProgressReactions(duration: TimeInterval) {
            reactionProgressModel.startReactionFromExisting(
                consuming: [
                    (.knownReactant, 1),
                    (.unknownReactant, unknownReactantCoeff)
                ],
                producing: [.product],
                count: reactionsToRun,
                duration: duration
            )
        }

        func canAdd(reactant: PrecipitationComponents.Reactant) -> Bool {
            false
        }

        func hasAddedEnough(of reactant: PrecipitationComponents.Reactant) -> Bool {
            true
        }

        mutating func add(reactant: PrecipitationComponents.Reactant, count: Int) {
        }
    }
}



