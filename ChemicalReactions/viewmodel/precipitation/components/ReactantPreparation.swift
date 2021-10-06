//
// Reactions App
//

import ReactionsCore
import CoreGraphics

extension PrecipitationComponents {
    struct ReactantPreparation: PhaseComponents {
        init(
            grid: BeakerGrid,
            reactant: Reactant,
            minToAdd: Int,
            maxToAdd: Int,
            previous: PhaseComponents?
        ) {
            let otherMolecules = Molecule.allCases.filter { $0 != reactant.molecule}
            let otherCoords = otherMolecules.flatMap { m in
                previous?.coords(for: m).coordinates ?? []
            }
            self.reactant = reactant
            self.previous = previous
            self.underlying = LimitedGridCoords(
                grid: grid,
                otherCoords: otherCoords,
                minToAdd: minToAdd,
                maxToAdd: maxToAdd
            )
        }

        let startOfReaction: CGFloat = 0
        let endOfReaction: CGFloat = 0
        let previouslyReactingUnknownReactantMoles: CGFloat = 0

        private var underlying: LimitedGridCoords
        private let reactant: Reactant
        private var previous: PhaseComponents?

        mutating func add(reactant: PrecipitationComponents.Reactant, count: Int) {
            guard reactant == self.reactant && underlying.canAdd else {
                return
            }
            underlying.add(count: count)
        }

        func coords(for molecule: PrecipitationComponents.Molecule) -> FractionedCoordinates {
            if molecule == reactant.molecule {
                return FractionedCoordinates(
                    coordinates: underlying.coords,
                    fractionToDraw: ConstantEquation(value: 1)
                )
            }
            if let previous = previous {
                return previous.coords(for: molecule)
            }
            return FractionedCoordinates(
                coordinates: [],
                fractionToDraw: ConstantEquation(value: 1)
            )
        }

        func canAdd(reactant: PrecipitationComponents.Reactant) -> Bool {
            reactant == self.reactant && underlying.canAdd
        }

        func hasAddedEnough(of reactant: PrecipitationComponents.Reactant) -> Bool {
            reactant != self.reactant || underlying.hasAddedEnough
        }
    }
}
