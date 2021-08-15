//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct EquilibriumMoleculeScales: View {

    let reaction: BalancedReactionEquation
    let angleFraction: Equation
    let currentTime: CGFloat

    var body: some View {
        let molecules = self.molecules
        return MoleculeScales(
            leftMolecules: .double(
                left: molecules.reactantA,
                right: molecules.reactantB
            ),
            rightMolecules: .double(
                left: molecules.productC,
                right: molecules.productD
            ),
            rotationFraction: angleFraction,
            equationInput: currentTime,
            cols: AqueousReactionSettings.Scales.pileCols,
            rows: AqueousReactionSettings.Scales.pileRows
        )
    }

    private var molecules: MoleculeValue<MoleculeScales.MoleculeEquation> {
        let fractionFactor = 1 / AqueousReactionSettings.Scales.concentrationForMaxBasketPile
        return .init { molecule in
            let concentration = reaction.concentration.value(for: molecule)
            let fractionToDraw = fractionFactor * concentration
            return .init(
                fractionToDraw: fractionToDraw,
                color: molecule.color,
                label: molecule.rawValue
            )
        }
    }

    private var moleculeFractionsToDraw: MoleculeValue<Equation> {
        let factor = 1 / AqueousReactionSettings.Scales.concentrationForMaxBasketPile
        return reaction.concentration.map { concentration in
            factor * concentration
        }
    }
}
