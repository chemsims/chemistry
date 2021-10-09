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
            grid: BeakerGrid
        ) {
            self.previous = previous
            self.precipitate = previous.precipitate

            let productCoords = previous.finalCoords(for: .product)
            let knownCoords = previous.finalCoords(for: .knownReactant)

            let unknownRequiredToConsumeAllOfKnown = unknownReactantCoeff * knownCoords.count

            self.underlying = LimitedGridCoords(
                grid: grid,
                initialCoords: [],
                otherCoords: knownCoords + productCoords,
                minToAdd: unknownRequiredToConsumeAllOfKnown,
                maxToAdd: unknownRequiredToConsumeAllOfKnown
            )
        }

        var precipitate: GrowingPolygon
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
        }

        func canAdd(reactant: Reactant) -> Bool {
            reactant == .unknown && underlying.canAdd
        }

        func hasAddedEnough(of reactant: Reactant) -> Bool {
            reactant != .unknown || underlying.hasAddedEnough
        }

    }
}
