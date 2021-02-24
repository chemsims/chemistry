//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ReactionsRateBeaker: View {

    let moleculesA: [GridCoordinate]
    let concentrationB: Equation?
    let currentTime: CGFloat?
    let reactionPair: ReactionPairDisplay
    let finalTime: CGFloat?

    var body: some View {
        FilledBeaker(
            molecules: [
                BeakerMolecules(
                    coords: moleculesA,
                    color: reactionPair.reactant.color
                )
            ],
            animatingMolecules: bMolecules ?? [],
            currentTime: currentTime ?? 0
        )
    }

    private var bMolecules: [AnimatingBeakerMolecules]? {
        concentrationB.flatMap { conB in
            finalTime.map { t2 in
                let numB = Int(conB.getY(at: t2) * CGFloat(gridSize))
                return [
                    AnimatingBeakerMolecules(
                        molecules: BeakerMolecules(
                            coords: moleculesA.suffix(numB),
                            color: reactionPair.product.color
                        ),
                        fractionToDraw:
                            ScaledEquation(
                                targetY: 1,
                                targetX: t2,
                                underlying: conB
                            )
                    )
                ]
            }
        }
    }

    private let gridSize = MoleculeGridSettings.cols * MoleculeGridSettings.rows
}

