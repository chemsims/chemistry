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

        var text: TextLine {
            if let charge = charge {
                return TextLine("\(symbol)^\(charge.rawValue)^")
            }
            return TextLine(symbol)
        }

        enum Charge: String {
            case positive = "+"
            case negative = "-"
        }
    }

    var titrant: Titrant {
        if type.isAcid {
            return .potassiumHydroxide
        }
        return .hydrogenChloride
    }
}

// MARK: Reaction definitions
extension AcidOrBase {
    var reactionDefinition: AcidReactionDefinition {
        AcidReactionDefinition(
            leftTerms: [],
            rightTerms: []
        )
    }

    var titrationReactionDefinition: AcidReactionDefinition {
        AcidReactionDefinition(
            leftTerms: [
                .init(
                    name: chargedSymbol(ofPart: .substance).text,
                    color: color(ofPart: .substance)
                ),
                .init(
                    name: titrationDefinitionTitrant,
                    color: titrant.maximumMolarityColor.color
                )
            ],
            rightTerms: [
                .init(
                    name: titrationDefinitionProduct,
                    color: color(ofPart: .secondaryIon)
                ),
                waterTerm
            ]
        )
    }

    private var titrationDefinitionTitrant: TextLine {
        if type.isStrong {
            return TextLine(titrant.name)
        } else if type.isAcid {
            return TextLine("OH")
        }
        return "H_3_O"
    }

    private var titrationDefinitionProduct: TextLine {
        let secondarySymbol = symbol(ofPart: .secondaryIon)
        switch type {
        case .strongAcid:
            return "K\(secondarySymbol)"
        case .strongBase:
            return "\(secondarySymbol)Cl"
        case .weakAcid:
            return "K\(secondarySymbol)"
        case .weakBase:
            return "H\(symbol(ofPart: .substance))"
        }
    }

    private var waterTerm: AcidReactionDefinition.Term {
        .init(name: "H_2_O", color: RGB.beakerLiquid.color)
    }

    private func term(ofPart part: SubstancePart) -> AcidReactionDefinition.Term {
        .init(
            name: chargedSymbol(ofPart: part).text,
            color: color(ofPart: part)
        )
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
        hydrogenChloride,
        hydrogenIodide,
        hydrogenBromide
    ]

    static let strongBases = [
        potassiumHydroxide,
        lithiumHydroxide,
        sodiumHydroxide
    ]

    static let weakAcids = [
        weakAcidHA,
        weakAcidHF,
        hydrogenCyanide
    ]

    static let weakBases = [
        weakBaseB,
        weakBaseF,
        weakBaseHS
    ]

    static let hydrogenChloride =
        AcidOrBase.strongAcid(secondaryIon: .Cl, color: .blue, kA: 0)

    static let hydrogenIodide =
        AcidOrBase.strongAcid(secondaryIon: .I, color: .red, kA: 0)

    static let hydrogenBromide =
        AcidOrBase.strongAcid(secondaryIon: .Br, color: .purple, kA: 0)

    static let potassiumHydroxide =
        AcidOrBase.strongBase(secondaryIon: .K, color: .green, kB: 0)

    static let lithiumHydroxide =
        AcidOrBase.strongBase(secondaryIon: .Li, color: .black, kB: 0)

    static let sodiumHydroxide =
        AcidOrBase.strongBase(secondaryIon: .Na, color: .orange, kB: 0)

    static let weakAcidHA =
        AcidOrBase.weakAcid(
            secondaryIon: .A,
            substanceAddedPerIon: NonZeroPositiveInt(2)!,
            color: .purple,
            kA: 7.3e-5
        )

    static let weakAcidHF =
        AcidOrBase.weakAcid(
            secondaryIon: .F,
            substanceAddedPerIon: NonZeroPositiveInt(3)!,
            color: .gray,
            kA: 4.5e-4
        )

    static let hydrogenCyanide =
        AcidOrBase.weakAcid(
            secondaryIon: .CN,
            substanceAddedPerIon: NonZeroPositiveInt(4)!,
            color: .black,
            kA: 9e-5
        )

    static let weakBaseB =
        AcidOrBase.weakBase(
            secondaryIon: .B,
            substanceAddedPerIon: NonZeroPositiveInt(3)!,
            color: .orange,
            kB: 4e-5
        )

    static let weakBaseF =
        AcidOrBase.weakBase(
            secondaryIon: .F,
            substanceAddedPerIon: NonZeroPositiveInt(4)!,
            color: .yellow,
            kB: 1.3e-5
        )

    static let weakBaseHS =
        AcidOrBase.weakBase(
            secondaryIon: .HS,
            substanceAddedPerIon: NonZeroPositiveInt(2)!,
            color: .orange,
            kB: 1e-3
        )
}
