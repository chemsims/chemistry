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
        color: Color,
        kA: CGFloat
    ) {
        self.init(
            substanceAddedPerIon: substanceAddedPerIon,
            primary: primary,
            secondary: secondary,
            concentrationAtMaxSubstance: concentrationAtMaxSubstance,
            color: color,
            kA: kA,
            kB: kA == 0 ? 0 : CGFloat.waterDissociationConstant / kA
        )
    }

    init(
        substanceAddedPerIon: PositiveInt,
        primary: PrimaryIon,
        secondary: SecondaryIon,
        concentrationAtMaxSubstance: CGFloat,
        color: Color,
        kB: CGFloat
    ) {
        self.init(
            substanceAddedPerIon: substanceAddedPerIon,
            primary: primary,
            secondary: secondary,
            concentrationAtMaxSubstance: concentrationAtMaxSubstance,
            color: color,
            kA: kB == 0 ? 0 : CGFloat.waterDissociationConstant / kB,
            kB: kB
        )
    }

    init(
        substanceAddedPerIon: PositiveInt,
        primary: PrimaryIon,
        secondary: SecondaryIon,
        concentrationAtMaxSubstance: CGFloat,
        color: Color,
        kA: CGFloat,
        kB: CGFloat
    ) {
        self.substanceAddedPerIon = substanceAddedPerIon
        self.primary = primary
        self.secondary = secondary
        self.concentrationAtMaxSubstance = concentrationAtMaxSubstance
        self.color = color
        self.kA = kA
        self.kB = kB
        self.pKA = kA == 0 ? 0 : -log10(kA)
        self.pKB = kB == 0 ? 0 : -log10(kB)
    }

    var id: String {
        symbol
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

    // TODO - make these private, or remove their conformance to String. Accessing their
    // labels should be done via the substance, not the ion directly
    let primary: PrimaryIon
    let secondary: SecondaryIon

    /// The maximum ion concentration
    let concentrationAtMaxSubstance: CGFloat

    /// Color of the substance
    let color: Color

    let kA: CGFloat
    let kB: CGFloat
    let pKA: CGFloat
    let pKB: CGFloat

    /// Returns a strong acid substance
    static func strongAcid(
        secondaryIon: SecondaryIon,
        color: Color,
        kA: CGFloat
    ) -> AcidOrBase {
        AcidOrBase(
            substanceAddedPerIon: PositiveInt(0)!,
            primary: .hydrogen,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1,
            color: color,
            kA: kA
        )
    }

    /// Returns a strong base substance
    static func strongBase(
        secondaryIon: SecondaryIon,
        color: Color,
        kB: CGFloat
    ) -> AcidOrBase {
        AcidOrBase(
            substanceAddedPerIon: PositiveInt(0)!,
            primary: .hydroxide,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1,
            color: color,
            kB: kB
        )
    }

    /// Returns a weak acid substance
    static func weakAcid(
        secondaryIon: SecondaryIon,
        substanceAddedPerIon: NonZeroPositiveInt,
        color: Color,
        kA: CGFloat
    ) -> AcidOrBase {
        AcidOrBase(
            substanceAddedPerIon: substanceAddedPerIon.positiveInt,
            primary: .hydrogen,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1 / CGFloat(substanceAddedPerIon.value),
            color: color,
            kA: kA
        )
    }

    /// Returns a weak base substance
    static func weakBase(
        secondaryIon: SecondaryIon,
        substanceAddedPerIon: NonZeroPositiveInt,
        color: Color,
        kB: CGFloat
    ) -> AcidOrBase {
        AcidOrBase(
            substanceAddedPerIon: substanceAddedPerIon.positiveInt,
            primary: .hydroxide,
            secondary: secondaryIon,
            concentrationAtMaxSubstance: 0.1 / CGFloat(substanceAddedPerIon.value),
            color: color,
            kB: kB
        )
    }

    var type: AcidOrBaseType {
        let isStrong = substanceAddedPerIon.value == 0
        switch primary {
        case .hydrogen where isStrong: return .strongAcid
        case .hydrogen: return .weakAcid
        case .hydroxide where isStrong: return .strongBase
        case .hydroxide: return .weakBase
        }
    }

    func color(ofPart part: SubstancePart) -> Color {
        switch part {
        case .substance: return color
        case .primaryIon: return primary.color
        case .secondaryIon: return secondary.color
        }
    }
}

// MARK: Symbol names
extension AcidOrBase {

    // TODO - remove the symbol method & param below
    func symbol(ofPart part: SubstancePart) -> String {
        chargedSymbol(ofPart: part).symbol
    }
    var symbol: String {
        if type == .weakBase {
            return "\(secondary.rawValue)"
        }
        if primary == .hydrogen {
            return "\(primary.rawValue)\(secondary.rawValue)"
        }
        return "\(secondary.rawValue)\(primary.rawValue)"
    }

    var productParts: [SubstancePart] {
        if type.isAcid {
            return [.primaryIon, .secondaryIon]
        }
        return [.secondaryIon, .primaryIon]
    }

    /// Returns the `ChargedSymbol` of the given `part` of the substance
    func chargedSymbol(ofPart part: SubstancePart) -> ChargedSymbol {
        switch part {
        case .substance: return chargedSymbol
        case .primaryIon: return primarySymbol
        case .secondaryIon: return secondarySymbol
        }
    }

    private var chargedSymbol: ChargedSymbol {
        if type == .weakBase {
            return ChargedSymbol(symbol: secondary.rawValue, charge: .negative)
        }

        let p = primary.rawValue
        let s = secondary.rawValue

        let name = primary == .hydrogen ? "\(p)\(s)" : "\(s)\(p)"
        return ChargedSymbol(symbol: name, charge: nil)
    }

    private var primarySymbol: ChargedSymbol {
        let charge: ChargedSymbol.Charge = primary == .hydrogen ? .positive : .negative
        return ChargedSymbol(symbol: primary.rawValue, charge: charge)
    }

    private var secondarySymbol: ChargedSymbol {
        if type == .weakBase {
            return ChargedSymbol(symbol: "\(secondary.rawValue)H", charge: nil)
        }
        let charge: ChargedSymbol.Charge = primary == .hydrogen ? .negative : .positive
        return ChargedSymbol(symbol: secondary.rawValue, charge: charge)
    }

    struct ChargedSymbol: Equatable {
        let symbol: String
        let charge: Charge?

        enum Charge: String {
            case positive = "+"
            case negative = "-"
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
        AcidOrBase.strongAcid(secondaryIon: .A, color: .blue, kA: 0),
        AcidOrBase.strongAcid(secondaryIon: .Cl, color: .red, kA: 0),
        AcidOrBase.strongAcid(secondaryIon: .Br, color: .purple, kA: 0)
    ]

    static let strongBases = [
        AcidOrBase.strongBase(secondaryIon: .K, color: .orange, kB: 0),
        AcidOrBase.strongBase(secondaryIon: .Na, color: .green, kB: 0),
        AcidOrBase.strongBase(secondaryIon: .Ba, color: .pink, kB: 0)
    ]

    static let weakAcids = [
        AcidOrBase.weakAcid(secondaryIon: .Ba, substanceAddedPerIon: NonZeroPositiveInt(2)!, color: .black, kA: 7.3e-5),
        AcidOrBase.weakAcid(secondaryIon: .Na, substanceAddedPerIon: NonZeroPositiveInt(3)!, color: .gray, kA: 4.5e-4),
        AcidOrBase.weakAcid(secondaryIon: .K, substanceAddedPerIon: NonZeroPositiveInt(4)!, color: .black, kA: 9e-5),
    ]

    static let weakBases = [
        AcidOrBase.weakBase(secondaryIon: .B, substanceAddedPerIon: NonZeroPositiveInt(3)!, color: .orange, kB: 4e-5),
        AcidOrBase.weakBase(secondaryIon: .Br, substanceAddedPerIon: NonZeroPositiveInt(4)!, color: .orange, kB: 1.3e-5),
        AcidOrBase.weakBase(secondaryIon: .Cl, substanceAddedPerIon: NonZeroPositiveInt(2)!, color: .orange, kB: 1e-3),
    ]
}
