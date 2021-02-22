//
// ReactionsCore
//

import Foundation

public enum ReactionType: Int, CaseIterable {
    case A, B, C
}

extension ReactionType: Identifiable {
    public var id: Int {
        self.rawValue
    }
}

extension ReactionType {
    public var name: String {
        "\(reactant) to \(product)"
    }

    // Accessibility label
    public var label: String {
        "'\(reactant)' to '\(product)'"
    }

    public var display: ReactionPairDisplay {
        ReactionPairDisplay(
            reactant: ReactionMoleculeDisplay(
                name: reactant,
                color: reactantColor.color
            ),
            product: ReactionMoleculeDisplay(
                name: product,
                color: productColor.color
            )
        )
    }

    public var reactant: String {
        switch self {
        case .A: return "A"
        case .B: return "C"
        case .C: return "E"
        }
    }

    public var product: String {
        switch self {
        case .A: return "B"
        case .B: return "D"
        case .C: return "F"
        }
    }

    public var reactantColor: RGB {
        switch self {
        case .A: return RGB.moleculeA
        case .B: return RGB.moleculeD
        case .C: return RGB.moleculeG
        }
    }

    public var productColor: RGB {
        switch self {
        case .A: return RGB.moleculeB
        case .B: return RGB.moleculeE
        case .C: return RGB.moleculeH
        }
    }
}
