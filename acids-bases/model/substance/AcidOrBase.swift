//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct AcidOrBase: Equatable {

    init(
        name: String,
        substanceAddedPerIon: PositiveInt,
        primary: PrimaryIon,
        secondary: SecondaryIon,
        concentrationAtMaxSubstance: CGFloat
    ) {
        self.name = name
        self.substanceAddedPerIon = substanceAddedPerIon
        self.primary = primary
        self.secondary = secondary
        self.concentrationAtMaxSubstance = concentrationAtMaxSubstance
    }

    /// Display name of the substance
    let name: String

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

    /// Returns a strong acid substance
    static func strongAcid(
        name: String,
        secondaryIon: SecondaryIon
    ) -> AcidOrBase {
        AcidOrBase(
            name: name,
            substanceAddedPerIon: PositiveInt(0)!,
            primary: .hydrogen,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1
        )
    }

    /// Returns a strong base substance
    static func strongBase(
        name: String,
        secondaryIon: SecondaryIon
    ) -> AcidOrBase {
        AcidOrBase(
            name: name,
            substanceAddedPerIon: PositiveInt(0)!,
            primary: .hydroxide,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1
        )
    }

    /// Returns a weak acid substance
    static func weakAcid(
        name: String,
        secondaryIon: SecondaryIon,
        substanceAddedPerIon: NonZeroPositiveInt
    ) -> AcidOrBase {
        AcidOrBase(
            name: name,
            substanceAddedPerIon: substanceAddedPerIon.positiveInt,
            primary: .hydrogen,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1 / CGFloat(substanceAddedPerIon.value)
        )
    }

    /// Returns a weak base substance
    static func weakBase(
        name: String,
        secondaryIon: SecondaryIon,
        substanceAddedPerIon: NonZeroPositiveInt
    ) -> AcidOrBase {
        AcidOrBase(
            name: name,
            substanceAddedPerIon: substanceAddedPerIon.positiveInt,
            primary: .hydroxide,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1 / CGFloat(substanceAddedPerIon.value)
        )
    }
}
