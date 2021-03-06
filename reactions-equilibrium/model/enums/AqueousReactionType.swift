//
// Reactions App
//

import CoreGraphics

enum AqueousReactionType: Int, CaseIterable, Identifiable {
    case A, B, C

    var id: Int {
        rawValue
    }
}

extension AqueousReactionType {
    var equilibriumConstant: CGFloat {
        switch self {
        case .A: return 0.75
        case .B: return 10
        case .C: return 2
        }
    }
}

extension AqueousReactionType {

    var displayName: String {
        func str(_ name: String, _ coeffs: Int) -> String {
            let coeffString = coeffs == 1 ? "" : "\(coeffs)"
            return "\(coeffString)\(name)"
        }

        let coeffs = coefficients
        let a = str("A", coeffs.reactantA)
        let b = str("B", coeffs.reactantB)
        let c = str("C", coeffs.productC)
        let d = str("D", coeffs.productD)

        return "\(a) + \(b) ⇌ \(c) + \(d)"
    }

    // TODO
    var label: String {
        displayName
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
}
