//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct AcidConcentrationEquations {

    /// Returns concentration equations for a substance whose concentration decreases, while the
    /// concentration of the ions increases.
    ///
    /// This uses the relation Ka = [primary][secondary]/[substance] to find the change in concentration.
    /// Each concentration changes by the same amount, and the ions start at a concentration of 0.
    ///
    /// The equation input uses the initial concentration at an input of 0, and the final concentration at an input of 1.
    static func concentrations(
        forPartsOf substance: AcidOrBase,
        initialSubstanceConcentration: CGFloat
    ) -> SubstanceValue<Equation> {
        let changeInConcentration = self.changeInConcentration(
            substance: substance,
            initialSubstanceConcentration: initialSubstanceConcentration
        )
        let ionEquation = LinearEquation(x1: 0, y1: 0, x2: 1, y2: changeInConcentration)
        return SubstanceValue(
            substance: LinearEquation(
                x1: 0,
                y1: initialSubstanceConcentration,
                x2: 1,
                y2: initialSubstanceConcentration - changeInConcentration
            ),
            primaryIon: ionEquation,
            secondaryIon: ionEquation
        )
    }


    // TODO - this should be removed. The equation for K = ... varies,
    // and should not be assumed
    /// Returns a change in concentration, given the equation for Ka:
    /// Ka = [primary][secondary]/[substance]
    ///
    /// We assume that primary and secondary start at 0, and all concentrations change by the same amount, x.
    /// So we have Ka = x^2/(S0 - x) where S0 is the initial substance concentration.
    ///
    /// Rearranging, we have x^2 + S0x - KaSo = 0
    static func changeInConcentration(
        substance: AcidOrBase,
        initialSubstanceConcentration: CGFloat
    ) -> CGFloat {
        changeInConcentration(
            kValue: substance.type.isAcid ? substance.kA : substance.kB,
            initialDenominatorConcentration: initialSubstanceConcentration
        )
    }

    /// Returns a change in concentration, given the equation of K:
    /// K = [C1][C2]/[C3]
    ///
    /// We assume that C1 and C2 start at 0, and all concentrations change by the same amount, x.
    /// So we have K = x^2/(C30 - x) where C0 is the initial concentration of the denominator term.
    ///
    /// Rearranging, we have x^2 + C30x - KC30 = 0
    static func changeInConcentration(
        kValue: CGFloat,
        initialDenominatorConcentration: CGFloat
    ) -> CGFloat {
        guard let roots = QuadraticEquation.roots(
            a: 1,
            b: kValue,
            c: -(kValue * initialDenominatorConcentration)
        ) else {
            return 0
        }

        guard let validRoot = [roots.0, roots.1].first(where: {
            $0 > 0 && $0 < (initialDenominatorConcentration / 2)
        }) else {
            return 0
        }

        return validRoot
    }
}
