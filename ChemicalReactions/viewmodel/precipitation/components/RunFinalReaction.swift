//
// Reactions App
//

import CoreGraphics
import ReactionsCore

extension PrecipitationComponents {
    struct RunFinalReaction: PhaseComponents {

        init(
            startOfReaction: CGFloat,
            endOfReaction: CGFloat,
            previous: PhaseComponents,
            previouslyReactingUnknownReactantMoles: CGFloat,
            grid: BeakerGrid
        ) {
            self.startOfReaction = startOfReaction
            self.endOfReaction = endOfReaction
            self.previous = previous
            self.previouslyReactingUnknownReactantMoles = previouslyReactingUnknownReactantMoles
            self.grid = grid

            let initialProductCoords = previous.coords(for: .product).coords(at: startOfReaction)
            let initialKnownReactantCoords = previous.coords(for: .knownReactant).coords(at: startOfReaction)

            // known reactant and product always have a coeff of 1, so the number of product coords
            // added is the same as known consumed
            let desiredCount = initialProductCoords.count + initialKnownReactantCoords.count
            let underlyingProductCoords = GridCoordinateList.spiralGrid(
                cols: grid.cols,
                rows: grid.rows,
                count: desiredCount
            )
            self.underlyingProductCoords = underlyingProductCoords
            self.initialProductCoordFraction = CGFloat(initialProductCoords.count) / CGFloat(desiredCount)
        }


        let startOfReaction: CGFloat
        let endOfReaction: CGFloat
        let previous: PhaseComponents
        let previouslyReactingUnknownReactantMoles: CGFloat
        let grid: BeakerGrid

        func coords(for molecule: PrecipitationComponents.Molecule) -> FractionedCoordinates {
            switch molecule {
            case .knownReactant, .unknownReactant: return decreasingMoleculesToZero(molecule: molecule)
            case .product: return productCoords
            }
        }

        private var productCoords: FractionedCoordinates {
            FractionedCoordinates(
                coordinates: underlyingProductCoords,
                fractionToDraw: LinearEquation(
                    x1: startOfReaction,
                    y1: initialProductCoordFraction,
                    x2: endOfReaction,
                    y2: 1
                )
            )
        }

        private let underlyingProductCoords: [GridCoordinate]
        private let initialProductCoordFraction: CGFloat


        private func decreasingMoleculesToZero(molecule: PrecipitationComponents.Molecule) -> FractionedCoordinates {
            let prevCoords = previous.coords(for: molecule).coords(at: startOfReaction)
            return FractionedCoordinates(
                coordinates: prevCoords,
                fractionToDraw: LinearEquation(
                    x1: startOfReaction,
                    y1: 1,
                    x2: endOfReaction,
                    y2: 0
                )
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
