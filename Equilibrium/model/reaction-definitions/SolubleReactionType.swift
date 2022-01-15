//
// Reactions App
//

import CoreGraphics
import SwiftUI
import ReactionsCore

enum SolubleReactionType: Int, CaseIterable, SelectableReaction {

    case A, B, C

    var id: Int {
        rawValue
    }

    var productText: TextLine {
        "\(products.first)^+^ + \(products.second)^-^"
    }

    var reactantDisplay: String {
        "\(products.salt)(s)"
    }

    var productDisplay: String {
        "\(products.first)^+^ + \(products.second)^-^"
    }

    var reactantLabel: String {
        "\(products.salt) (s in parenthesis)"
    }

    var productLabel: String {
        "\(products.first) superscript plus sign, + \(products.second) superscript minus sign"
    }

    var products: SolubleProductPair {
        switch self {
        case .A: return SolubleProductPair(first: "A", second: "B", third: "C")
        case .B: return SolubleProductPair (first: "C", second: "D", third: "E")
        case .C: return SolubleProductPair (first: "E", second: "F", third: "B")
        }
    }

    var solubility: SolublePhCurve {
        switch self {
        case .A: return .curve1
        case .B: return .curve2
        case .C: return .curve3
        }
    }

    var soluteColor: RGB {
        switch self {
        case .A: return .primarySoluteA
        case .B: return .primarySoluteB
        case .C: return .primarySoluteC
        }
    }

    var saturatedLiquid: RGB {
        switch self {
        case .A: return .saturatedLiquidA
        case .B: return .saturatedLiquidB
        case .C: return .saturatedLiquidC
        }
    }

    var commonIonSolute: RGB {
        switch self {
        case .A: return .commonIonSoluteA
        case .B: return .commonIonSoluteB
        case .C: return .commonIonSoluteC
        }
    }

    var maxCommonIonLiquid: RGB {
        switch self {
        case .A: return .maxCommonIonLiquidA
        case .B: return .maxCommonIonLiquidB
        case .C: return .maxCommonIonLiquidC
        }
    }
}

struct SolubleProductPair {
    let first: String
    let second: String
    let third: String

    var salt: String {
        "\(first)\(second)"
    }

    var commonSalt: String {
        "\(third)\(second)"
    }
}

struct SolublePhCurve {
    let curve: SolubilityChartEquation
    let startingPh: CGFloat
    let saturatedSolubility: CGFloat
    let superSaturatedSolubility: CGFloat
    let phForAcidSaturation: CGFloat

    init(curve: SolubilityChartEquation, startingPh: CGFloat) {
        self.curve = curve
        self.startingPh = startingPh
        self.saturatedSolubility = curve.getValue(at: startingPh)

        let superSaturatedSolubility = 1.25 * saturatedSolubility
        self.superSaturatedSolubility = superSaturatedSolubility
        self.phForAcidSaturation = curve.getLeftHandPh(for: superSaturatedSolubility)!
    }


    fileprivate static let curve1 = SolublePhCurve(
        curve: SolubilityChartEquation(
            zeroPhSolubility: 1,
            maxPhSolubility: 0.9,
            minSolubility: 0.3,
            phAtMinSolubility: 0.6
        ),
        startingPh: 0.88
    )

    fileprivate static let curve2 = SolublePhCurve(
        curve: SolubilityChartEquation(
            zeroPhSolubility: 0.9,
            maxPhSolubility: 1,
            minSolubility: 0.25,
            phAtMinSolubility: 0.55
        ),
        startingPh: 0.88
    )

    fileprivate static let curve3 = SolublePhCurve(
        curve: SolubilityChartEquation(
            zeroPhSolubility: 1,
            maxPhSolubility: 0.8,
            minSolubility: 0.35,
            phAtMinSolubility: 0.4
        ),
        startingPh: 0.88
    )

}
