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
            finalReactionProgress: CGFloat,
            grid: BeakerGrid
        ) {
            self.unknownReactantCoeff = unknownReactantCoeff
            self.previous = previous
            self.finalReactionProgress = finalReactionProgress
            self.grid = grid

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
            let knownCoordsSet = Set(knownReactantCoords)

            // We'd like to first consume any known coords which intersect the product coords
            let knownCoordsIntersectingProduct = knownCoordsSet.intersection(productCoordsSet)
            let otherKnownCoords = knownCoordsSet.subtracting(knownCoordsIntersectingProduct)

            self.knownReactantToConsume = knownReactantToConsume
            self.underlyingProductCoords = productCoords
            self.underlyingKnownCoords = Array(otherKnownCoords) + Array(knownCoordsIntersectingProduct)

        }

        let unknownReactantCoeff: Int
        let previous: PhaseComponents
        let finalReactionProgress: CGFloat
        let grid: BeakerGrid

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
                    x2: finalReactionProgress,
                    y2: finalFraction
                )
            )
        }

        private var unknownReactantCoords: FractionedCoordinates {
            FractionedCoordinates(
                coordinates: previous.coords(for: .unknownReactant).coordinates,
                fractionToDraw: LinearEquation(
                    x1: 0,
                    y1: 1,
                    x2: finalReactionProgress,
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
                    x2: finalReactionProgress,
                    y2: 1
                )
            )
        }

        private let knownReactantToConsume: CGFloat
        private let underlyingProductCoords: [GridCoordinate]
        private let underlyingKnownCoords: [GridCoordinate]

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



