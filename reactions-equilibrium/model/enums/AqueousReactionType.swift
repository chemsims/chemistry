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

    var pressureConstant: CGFloat {
        let productCoeffs = coefficients.productC + coefficients.productD
        let reactantCoeffs = coefficients.reactantA + coefficients.reactantB
        let factor = pow(GaseousReactionSettings.pressureToConcentration, CGFloat(productCoeffs - reactantCoeffs))
        return equilibriumConstant * factor
    }
}

extension AqueousReactionType {

    var displayName: String {
        "\(reactantDisplay) ⇌ \(productDisplay)"
    }


    var reactantDisplay: String {
        let a = moleculeString("A", coeff: coefficients.reactantA)
        let b = moleculeString("B", coeff: coefficients.reactantB)
        return "\(a) + \(b)"
    }

    var productDisplay: String {
        let a = moleculeString("C", coeff: coefficients.productC)
        let b = moleculeString("D", coeff: coefficients.productD)
        return "\(a) + \(b)"
    }

    private func moleculeString(_ name: String, coeff: Int) -> String {
        let coeffString = coeff == 1 ? "" : "\(coeff)"
        return "\(coeffString)\(name)"
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
