//
// Reactions App
//

import CoreGraphics
import ReactionsCore

extension PrecipitationComponents {
    struct FinalReaction: PrecipitationComponentsReaction {

        init(
            unknownReactantCoeff: Int,
            startOfReaction: CGFloat,
            previous: ExtraUnknownReactantPreparation,
            previouslyReactingUnknownReactantMoles: CGFloat,
            grid: BeakerGrid
        ) {
            self.unknownReactantCoeff = unknownReactantCoeff
            self.previous = previous

            let initialProductCoords = previous.initialCoords(for: .product)
            let initialKnownReactantCoords = previous.initialCoords(for: .knownReactant)

            // known reactant and product always have a coeff of 1, so the
            // number of product coords added is the same as known consumed
            let productsToAdd = initialKnownReactantCoords.count

            let finalProductCoords = GridCoordinateList.randomGrowth(
                cols: grid.cols,
                rows: grid.rows,
                count: productsToAdd,
                existing: initialProductCoords
            )

            self.initialProductCoords = initialProductCoords
            self.finalProductCoords = finalProductCoords
            self.reactionProgressModel = previous.reactionProgressModel.copy()
        }

        let unknownReactantCoeff: Int
        let previous: PrecipitationComponents.ExtraUnknownReactantPreparation
        let reactionProgressModel: ReactionProgressModel

        func initialCoords(for molecule: PrecipitationComponents.Molecule) -> [GridCoordinate] {
            if molecule == .product {
                return initialProductCoords
            }
            return previous.initialCoords(for: molecule)
        }

        func finalCoords(for molecule: PrecipitationComponents.Molecule) -> [GridCoordinate] {
            if molecule == .product {
                return finalProductCoords
            }
            return []
        }

        private let initialProductCoords: [GridCoordinate]
        private let finalProductCoords: [GridCoordinate]

        var reactionsToRun: Int {
            reactionProgressModel.moleculeCounts(ofType: .knownReactant)
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
