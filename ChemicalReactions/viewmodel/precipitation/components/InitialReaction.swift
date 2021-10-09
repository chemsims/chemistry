//
// Reactions App
//

import ReactionsCore
import CoreGraphics

extension PrecipitationComponents {

    struct InitialReaction: PrecipitationComponentsReaction {

        init(
            unknownReactantCoeff: Int,
            previous: UnknownReactantPreparation,
            grid: BeakerGrid
        ) {
            self.reactionProgressModel = previous.reactionProgressModel.copy()
            self.precipitate = previous.precipitate
            self.previous = previous
            self.unknownReactantCoeff = unknownReactantCoeff

            let unknownReactantCount = previous.initialCoords(for: .unknownReactant).count
            let knownReactantToConsume = (CGFloat(unknownReactantCount) / CGFloat(unknownReactantCoeff)).roundedInt()

            /// The coeff of both product and known reactant is always 1, so the amount of known
            /// reactant consumed is the same as product produced
            let productToAdd = knownReactantToConsume

            let productCoords = GridCoordinateList.randomGrowth(
                cols: grid.cols,
                rows: grid.rows,
                count: productToAdd
            )

            let prevKnownReactantCoords = previous.initialCoords(for: .knownReactant)

            let productCoordsSet = Set(productCoords)

            // We'd like to first consume any known coords which intersect the product coords
            let knownCoordsIntersectingProduct = prevKnownReactantCoords.filter {
                productCoordsSet.contains($0)
            }
            let otherKnownCoords = prevKnownReactantCoords.filter {
                !productCoordsSet.contains($0)
            }

            let initialKnownCoords = otherKnownCoords + knownCoordsIntersectingProduct
            let finalKnownCoords = Array(initialKnownCoords.dropLast(knownReactantToConsume))

            self.initialKnownReactantCoords = initialKnownCoords
            self.finalKnownReactantCoords = finalKnownCoords
            self.finalProductCoords = productCoords
        }

        let reactionProgressModel: ReactionProgressModel
        var precipitate: GrowingPolygon
        let previous: UnknownReactantPreparation
        let unknownReactantCoeff: Int
        
        func initialCoords(for molecule: Molecule) -> [GridCoordinate] {
            // The known reactant coords are re-ordered to make sure we consume those
            // overlapping the product first, so don't return coords from previous phase
            if molecule == .knownReactant {
                return initialKnownReactantCoords
            }
            return previous.initialCoords(for: molecule)
        }

        func finalCoords(for molecule: Molecule) -> [GridCoordinate] {
            switch molecule {
            case .knownReactant: return finalKnownReactantCoords
            case .unknownReactant: return []
            case .product: return finalProductCoords
            }
        }

        private let initialKnownReactantCoords: [GridCoordinate]
        private let finalProductCoords: [GridCoordinate]
        private let finalKnownReactantCoords: [GridCoordinate]

        var reactionsToRun: Int {
            let unknownMoleculeCount = reactionProgressModel.moleculeCounts(ofType: .unknownReactant)
            let multiples = unknownMoleculeCount / unknownReactantCoeff
            if unknownMoleculeCount % unknownReactantCoeff == 0 {
                return multiples
            }

            // We need to run an extra reaction if we still have some unknown reactant left over
            return multiples + 1
        }

        func runOneReactionProgressReaction() {
            reactionProgressModel.startReactionFromExisting(
                consuming: [
                    (.knownReactant, 1),
                    (.unknownReactant, unknownReactantCoeff)
                ],
                producing: [.product],
                eagerReaction: true
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
                duration: duration,
                eagerReaction: true
            )
        }
    }
}
