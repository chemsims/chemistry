//
// Reactions App
//

import SwiftUI
import ReactionsCore

enum SoluteType {
    case primary, commonIon, acid

    func color(for reaction: SolubleReactionType) -> RGB {
        switch self {
        case .primary: return reaction.soluteColor
        case .commonIon: return reaction.commonIonSolute
        case .acid: return RGB.acidSolute
        }
    }


    func reaction(for type: SolubleReactionType) -> String {
        let products = type.products
        switch self {
        case .primary:
            return "\(products.salt)(s) ⇌ \(products.first)^+^ + \(products.second)^-^"
        case .commonIon:
            return "\(products.commonSalt)(s) ⇌ \(products.third)^+^ + \(products.second)^-^"
        case .acid:
            return "H^+^ + \(products.second)^-^ ⇌  H\(products.second)(aq)"
        }
    }

    func reactionLabel(for type: SolubleReactionType) -> String {
        let products = type.products

        func positive(_ base: String) -> String {
            "\(base) superscript plus sign"
        }
        func negative(_ base: String) -> String {
            "\(base) superscript minus sign"
        }

        switch self {
        case .primary:
            return "\(products.salt)(s) double-sided-arrow \(positive(products.first)) + \(negative(products.second))"
        case .commonIon:
            return "\(products.commonSalt)(s) double-sided-arrow \(positive(products.third)) + \(negative(products.second))"
        case .acid:
            return "\(positive("H")) + \(negative(products.second)) double-sided-arrow  H\(products.second)(aq)"
        }
    }

    func tooltipBackground(for type: SolubleReactionType) -> Color {
        switch self {
        case .primary: return type.saturatedLiquid.color
        case .commonIon: return type.maxCommonIonLiquid.color
        case .acid: return RGB.maxAcidLiquid.color
        }
    }

    func tooltipBorder(for type: SolubleReactionType) -> Color {
        switch self {
        case .primary: return type.soluteColor.color
        case .commonIon: return type.commonIonSolute.color
        case .acid: return RGB.acidSolute.color
        }
    }
}
