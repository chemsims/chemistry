//
// Reactions App
//

import CoreGraphics

enum GaseousReactionType: Int, ReactionDefinition, CaseIterable {
    case A, B, C

    var id: Int {
        rawValue
    }

    var equilibriumConstant: CGFloat {
        switch self {
        case .A: return 10000
        case .B: return 0.01
        case .C: return 50
        }
    }

    var coefficients: BalancedReactionCoefficients {
        switch self {
        case .A:
            return BalancedReactionCoefficients(
                reactantA: 3,
                reactantB: 4,
                productC: 1,
                productD: 2
            )
        case .B:
            return BalancedReactionCoefficients(
                reactantA: 1,
                reactantB: 2,
                productC: 3,
                productD: 4
            )
        case .C:
            return BalancedReactionCoefficients(
                reactantA: 4,
                reactantB: 2,
                productC: 1,
                productD: 2
            )
        }
    }
}
