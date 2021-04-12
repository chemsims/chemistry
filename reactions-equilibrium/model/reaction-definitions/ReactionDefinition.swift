//
// Reactions App
//

import CoreGraphics
import ReactionsCore

protocol SelectableReaction: Identifiable, Equatable, Labelled {
    var reactantDisplay: String { get }
    var productDisplay: String { get }
}

protocol ReactionDefinition: SelectableReaction {
    var equilibriumConstant: CGFloat { get }
    var coefficients: BalancedReactionCoefficients { get }
}

extension ReactionDefinition {

    var pressureConstant: CGFloat {
        GaseousReactionSettings.pressureConstantFromConcentrationConstant(equilibriumConstant, coefficients: coefficients)
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

    var displayName: String {
        "\(reactantDisplay) ⇌ \(productDisplay)"
    }

    // TODO
    var label: String {
        displayName
    }

    private func moleculeString(_ name: String, coeff: Int) -> String {
        let coeffString = coeff == 1 ? "" : "\(coeff)"
        return "\(coeffString)\(name)"
    }
}
