//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct PrimaryIonConcentration {

    /// The ion concentration
    /// - Note: This is the *actual* concentration of ion, not what is shown in the beaker.
    ///         It will be very small, between 1x10^-1 and 1x10^-14.
    let concentration: CGFloat

    /// The 'p' measure of concentration, say pH or pOH.
    let p: CGFloat

    init(concentration: CGFloat) {
        self.init(concentration: concentration, p: Self.pValue(forConcentration: concentration))
    }

    init(p: CGFloat) {
        self.init(concentration: Self.concentration(forP: p), p: p)
    }

    init(concentration: CGFloat, p: CGFloat) {
        self.concentration = concentration
        self.p = p
    }
}

extension PrimaryIonConcentration {

    /// Returns concentration for an ion whose concentration increases linearly as substance is added
    static func varyingPWithSubstance(
        fractionSubstanceAdded: CGFloat,
        initialConcentration: CGFloat = 1e-7,
        finalConcentration: CGFloat = 1e-1
    ) -> PrimaryIonConcentration {
        let concentration = LinearEquation(
            x1: 0,
            y1: initialConcentration,
            x2: 1,
            y2: finalConcentration
        ).getValue(at: fractionSubstanceAdded)

        return PrimaryIonConcentration(concentration: concentration)
    }

    static func addingToPh14(
        otherIonPh: CGFloat
    ) -> PrimaryIonConcentration {
        PrimaryIonConcentration(p: 14 - otherIonPh)
    }

    static func pValue(forConcentration concentration: CGFloat) -> CGFloat {
        -safeLog10(concentration)
    }

    static func concentration(forP p: CGFloat) -> CGFloat {
        pow(10, -p)
    }


    /// Returns the concentration of the complement to the primary ion, given the concentration of the primary ion.
    ///
    /// For example, if the primary ion is hydrogen and its concentration is `primaryConcentration`, then
    /// the concentration of hydroxide is returned such that the relation `14 = pH + pOH` is satisfied.
    static func complementConcentration(primaryConcentration: CGFloat) -> CGFloat {
        let pPrimary = pValue(forConcentration: primaryConcentration)
        let pComplement = 14 - pPrimary
        return concentration(forP: pComplement)
    }
}
