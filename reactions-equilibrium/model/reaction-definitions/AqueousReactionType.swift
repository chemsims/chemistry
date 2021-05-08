//
// Reactions App
//

import CoreGraphics

enum AqueousReactionType: Int, ReactionDefinition, CaseIterable {
    case A, B, C

    var id: Int {
        rawValue
    }

    var equilibriumConstant: CGFloat {
        switch self {
        case .A: return 0.75
        case .B: return 10
        case .C: return 2
        }
    }

    var coefficients: BalancedReactionCoefficients {
        switch self {
        case .A:
            return BalancedReactionCoefficients(
                reactantA: 1,
                reactantB: 1,
                productC: 1,
                productD: 1
            )
        case .B:
            return BalancedReactionCoefficients(
                reactantA: 3,
                reactantB: 2,
                productC: 1,
                productD: 2
            )
        case .C:
            return BalancedReactionCoefficients(
                reactantA: 2,
                reactantB: 3,
                productC: 1,
                productD: 4
            )
        }
    }

    var forwardRateConstant: CGFloat {
        switch self {
        case .A: return 0.5
        case .B: return 1.5
        case .C: return 0.9
        }
    }

    var reverseRateConstant: CGFloat {
        1 / (equilibriumConstant / forwardRateConstant)
    }
}
