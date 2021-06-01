//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidOrBase: Equatable, Identifiable {

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

    var id: String {
        symbol
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

    var type: AcidOrBaseType {
        let isStrong = substanceAddedPerIon.value > 0
        switch primary {
        case .hydrogen where isStrong: return .strongAcid
        case .hydrogen: return .weakAcid
        case .hydroxide where isStrong: return .strongBase
        case .hydroxide: return .weakBase
        }
    }
}

// MARK: Default substances
extension AcidOrBase {

    static func substances(forType type: AcidOrBaseType) -> [AcidOrBase] {
        switch type {
        case .strongAcid: return strongAcids
        case .strongBase: return strongBases
        case .weakAcid: return weakAcids
        case .weakBase: return weakBases
        }
    }

    static let strongAcids = [
        AcidOrBase.strongAcid(secondaryIon: .A, color: .blue),
        AcidOrBase.strongAcid(secondaryIon: .Cl, color: .red),
        AcidOrBase.strongAcid(secondaryIon: .Br, color: .purple)
    ]

    static let strongBases = [
        AcidOrBase.strongBase(secondaryIon: .K, color: .orange),
        AcidOrBase.strongBase(secondaryIon: .Na, color: .green),
        AcidOrBase.strongBase(secondaryIon: .Ba, color: .pink)
    ]

    static let weakAcids = [
        AcidOrBase.weakAcid(secondaryIon: .Ba, substanceAddedPerIon: NonZeroPositiveInt(2)!, color: .black),
        AcidOrBase.weakAcid(secondaryIon: .Na, substanceAddedPerIon: NonZeroPositiveInt(3)!, color: .gray),
        AcidOrBase.weakAcid(secondaryIon: .K, substanceAddedPerIon: NonZeroPositiveInt(4)!, color: .black),
    ]

    static let weakBases = [
        AcidOrBase.weakBase(secondaryIon: .A, substanceAddedPerIon: NonZeroPositiveInt(3)!, color: .orange),
        AcidOrBase.weakBase(secondaryIon: .Br, substanceAddedPerIon: NonZeroPositiveInt(4)!, color: .orange),
        AcidOrBase.weakBase(secondaryIon: .Cl, substanceAddedPerIon: NonZeroPositiveInt(2)!, color: .orange),
    ]
}
