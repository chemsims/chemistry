//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidOrBase: Equatable {

    init(
        substanceAddedPerIon: PositiveInt,
        primary: PrimaryIon,
        secondary: SecondaryIon,
        concentrationAtMaxSubstance: CGFloat,
        color: Color
    ) {
        self.substanceAddedPerIon = substanceAddedPerIon
        self.primary = primary
        self.secondary = secondary
        self.concentrationAtMaxSubstance = concentrationAtMaxSubstance
        self.color = color
    }

    var symbol: String {
        if primary == .hydrogen {
            return "\(primary.rawValue)\(secondary.rawValue)"
        }
        return "\(secondary.rawValue)\(primary.rawValue)"
    }

    /// Number of substance molecules added for each pair of ions which are produced
    ///
    /// When this is 0 then substance immediately ionizes and also does not remain in the liquid
    ///
    /// - Examples:
    ///     - 0: Substance ionizes when entering liquid with no substance remaining in liquid
    ///     - 1: Substance ionizes when entering liquid, while also remaining in the liquid
    ///     - 2: Every 2nd substance ionizes when entering liquid, while also remaining in the liquid
    let substanceAddedPerIon: PositiveInt

    let primary: PrimaryIon
    let secondary: SecondaryIon

    /// The maximum ion concentration
    let concentrationAtMaxSubstance: CGFloat

    /// Color of the substance
    let color: Color

    /// Returns a strong acid substance
    static func strongAcid(
        secondaryIon: SecondaryIon,
        color: Color
    ) -> AcidOrBase {
        AcidOrBase(
            substanceAddedPerIon: PositiveInt(0)!,
            primary: .hydrogen,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1,
            color: color
        )
    }

    /// Returns a strong base substance
    static func strongBase(
        secondaryIon: SecondaryIon,
        color: Color
    ) -> AcidOrBase {
        AcidOrBase(
            substanceAddedPerIon: PositiveInt(0)!,
            primary: .hydroxide,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1,
            color: color
        )
    }

    /// Returns a weak acid substance
    static func weakAcid(
        secondaryIon: SecondaryIon,
        substanceAddedPerIon: NonZeroPositiveInt,
        color: Color
    ) -> AcidOrBase {
        AcidOrBase(
            substanceAddedPerIon: substanceAddedPerIon.positiveInt,
            primary: .hydrogen,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1 / CGFloat(substanceAddedPerIon.value),
            color: color
        )
    }

    /// Returns a weak base substance
    static func weakBase(
        secondaryIon: SecondaryIon,
        substanceAddedPerIon: NonZeroPositiveInt,
        color: Color
    ) -> AcidOrBase {
        AcidOrBase(
            substanceAddedPerIon: substanceAddedPerIon.positiveInt,
            primary: .hydroxide,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1 / CGFloat(substanceAddedPerIon.value),
            color: color
        )
    }
}
