//
// Reactions App
//

import Foundation
import CoreGraphics

enum SolubleReactionType: Int, CaseIterable, SelectableReaction {

    case A, B, C

    var id: Int {
        rawValue
    }

    var reactantDisplay: String {
        "\(products.concatenated)(s)"
    }

    var productDisplay: String {
        "\(products.first)+ + \(products.second)-"
    }

    var products: SolubleProductPair {
        switch self {
        case .A: return SolubleProductPair(first: "A", second: "B")
        case .B: return SolubleProductPair (first: "C", second: "D")
        case .C: return SolubleProductPair (first: "E", second: "F")
        }
    }

    var solubility: SolublePhCurve {
        switch self {
        case .A: return .curve1
        case .B: return .curve2
        case .C: return .curve3
        }
    }

}

struct SolubleProductPair {
    let first: String
    let second: String

    var concatenated: String {
        "\(first)\(second)"
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
        self.saturatedSolubility = curve.getY(at: startingPh)

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
