//
// Reactions App
//

import Foundation

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
}

struct SolubleProductPair {
    let first: String
    let second: String

    var concatenated: String {
        "\(first)\(second)"
    }
}
