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
        symbol.asString
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

    let kA: CGFloat
    let kB: CGFloat
    let pKA: CGFloat
    let pKB: CGFloat
}

extension AcidOrBase {
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

    var saltName: String {
        let plainSecondary = chargedSymbol(ofPart: .secondaryIon).symbol.asString
        return type.isAcid ? "M\(plainSecondary)" : "\(plainSecondary)X"
    }
}

extension AcidOrBase {
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
}



// MARK: Symbol names
extension AcidOrBase {

    var symbol: TextLine {
        chargedSymbol(ofPart: .substance).text
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

    func accessibilityLabel(ofPart part: SubstancePart) -> String {
        chargedSymbol(ofPart: part).text.label
    }

    var chargedSymbol: ChargedSymbol {
        if type == .weakBase {
            return ChargedSymbol(symbol: TextLine(secondary.rawValue), charge: .negative)
        }

        let p = primary.rawValue
        let s = secondary.rawValue

        let name = primary == .hydrogen ? "\(p)\(s)" : "\(s)\(p)"
        return ChargedSymbol(symbol: TextLine(name), charge: nil)
    }

    private var primarySymbol: ChargedSymbol {
        let charge: ChargedSymbol.Charge = primary == .hydrogen ? .positive : .negative
        return ChargedSymbol(symbol: TextLine(primary.rawValue), charge: charge)
    }

    private var secondarySymbol: ChargedSymbol {
        if type == .weakBase {
            return ChargedSymbol(
                symbol: TextLine(
                    Self.prependingHydrogen(to: secondary.rawValue)
                ),
                charge: nil
            )
        }
        let charge: ChargedSymbol.Charge = primary == .hydrogen ? .negative : .positive
        return ChargedSymbol(symbol: TextLine(secondary.rawValue), charge: charge)
    }

    struct ChargedSymbol: Equatable {
        let symbol: TextLine
        let charge: Charge?

        var text: TextLine {
            if let charge = charge {
                return TextLine("\(symbol.asMarkdown)^\(charge.rawValue)^")
            }
            return symbol
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

        let substance = term(ofPart: .substance)
        let primary = reactionDefinitionPrimaryProduct
        let secondary = term(ofPart: .secondaryIon)

        let leftTerms = type.isStrong ? [substance] : [substance, waterTerm]

        let rightTerms = type.isAcid ? [primary, secondary] : [secondary, primary]

        return AcidReactionDefinition(
            leftTerms: leftTerms,
            rightTerms: rightTerms
        )
    }

    private var reactionDefinitionPrimaryProduct: AcidReactionDefinition.Term {
        switch type {
        case .strongAcid, .strongBase, .weakBase:
            return term(ofPart: .primaryIon)
        case .weakAcid:
            return .init(name: "H_3_O^+^", color: RGB.hydrogen.color)
        }
    }

    var titrationReactionDefinition: AcidReactionDefinition {
        AcidReactionDefinition(
            leftTerms: [
                term(ofPart: .substance),
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

    private func term(ofPart part: SubstancePart) -> AcidReactionDefinition.Term {
        .init(name: chargedSymbol(ofPart: part).text, color: color(ofPart: part))
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
        let secondarySymbol = chargedSymbol(ofPart: .secondaryIon).symbol.asString
        switch type {
        case .strongAcid:
            return "K\(secondarySymbol)"
        case .strongBase:
            return "\(secondarySymbol)Cl"
        case .weakAcid:
            return "K\(secondarySymbol)"
        case .weakBase:
            let symbolString = chargedSymbol(ofPart: .substance).symbol.asString
            return TextLine(Self.prependingHydrogen(to: symbolString))
        }
    }

    private var waterTerm: AcidReactionDefinition.Term {
        .init(name: "H_2_O", color: RGB.beakerLiquid.color)
    }
}

extension AcidOrBase {

    /// Returns `symbol` with `H` prepended. If there is already a hydrogen element
    /// in the symbol, then we return `H_2_` as a prefix. Note that in this case
    /// we expect exactly 1 'H' value since we do not support multiple counts,
    /// and we also assume any H in the element is a hydrogen element, rather than any other
    /// element containing the letter H. This is since none of our substances support such
    /// elements.
    private static func prependingHydrogen(
        to symbol: String
    ) -> String {

        let countOfH = symbol.filter { $0 == "H" }.count
        assert(
            countOfH < 2,
            "Expected no more than 1 H value in \(symbol)"
        )
        if countOfH != 1 {
            return "H\(symbol)"
        }

        let withoutH = symbol.filter { $0 != "H" }
        return "H_2_\(withoutH)"
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
