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
            reactionProgressModel: ReactionProgressChartViewModel<PrecipitationComponents.Molecule>,
            previous: PhaseComponents?,
            previouslyReactingUnknownReactantMoles: CGFloat = 0
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
            self.previouslyReactingUnknownReactantMoles = previouslyReactingUnknownReactantMoles
            self.reactionProgressModel = reactionProgressModel
        }

        let reactionProgressModel: ReactionProgressChartViewModel<PrecipitationComponents.Molecule>
        let startOfReaction: CGFloat = 0
        let endOfReaction: CGFloat = 0
        let previouslyReactingUnknownReactantMoles: CGFloat

        private var underlying: LimitedGridCoords
        private let reactant: Reactant
        let previous: PhaseComponents?

        mutating func add(reactant: PrecipitationComponents.Reactant, count: Int) {
            guard reactant == self.reactant && underlying.canAdd else {
                return
            }
            underlying.add(count: count)
            let concentration = underlying.grid.concentration(count: underlying.coords.count)
            let desiredRPMolecules = (concentration * 10).roundedInt()
            let currentRPMolecules = reactionProgressModel.moleculeCounts(ofType: reactant.molecule)
            let deficit = desiredRPMolecules - currentRPMolecules
            if deficit > 0 {
                reactionProgressModel.addMolecules(reactant.molecule, count: deficit, duration: 0.5)
            }
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

        let reactionsToRun = 0

        func runOneReactionProgressReaction() {
        }

        func runAllReactionProgressReactions(duration: TimeInterval) {
        }
    }
}
