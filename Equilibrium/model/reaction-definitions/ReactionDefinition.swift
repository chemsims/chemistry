//
// Reactions App
//

import CoreGraphics
import ReactionsCore

protocol SelectableReaction: Identifiable, Equatable, Labelled {
    var reactantDisplay: String { get }
    var productDisplay: String { get }

    var reactantLabel: String { get }
    var productLabel: String { get }
}

extension SelectableReaction {
    var displayName: String {
        "\(reactantDisplay) ⇌ \(productDisplay)"
    }

    var label: String {
        "\(reactantLabel), double-sided arrow, \(productLabel)"
    }
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
        let a = coefficients.string(forMolecule: .A)
        let b = coefficients.string(forMolecule: .B)
        return "\(a) + \(b)"
    }

    var productDisplay: String {
        let c = coefficients.string(forMolecule: .C)
        let d = coefficients.string(forMolecule: .D)
        return "\(c) + \(d)"
    }

    var reactantLabel: String {
        reactantDisplay
    }

    var productLabel: String {
        productDisplay
    }
}

extension BalancedReactionCoefficients {

    func string(forMolecule molecule: AqueousMolecule) -> String {
        let coeff = self.value(for: molecule)
        let coeffString = coeff == 1 ? "" : "\(coeff)"
        return "\(coeffString)\(molecule.rawValue)"
    }
}
