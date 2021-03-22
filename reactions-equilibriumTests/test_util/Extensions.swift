//
// Reactions App
//

import Foundation
import CoreGraphics
import ReactionsCore
@testable import reactions_equilibrium

extension BalancedReactionCoefficients {
    static let unit = BalancedReactionCoefficients(reactantA: 1, reactantB: 1, productC: 1, productD: 1)
}

extension BalancedReactionEquation {
    func withA0(_ newValue: CGFloat) -> BalancedReactionEquation {
        withInitialConcentration(newValue, for: .A)
    }

    func withB0(_ newValue: CGFloat) -> BalancedReactionEquation {
        withInitialConcentration(newValue, for: .B)
    }

    func withInitialConcentration(_ newValue: CGFloat, for molecule: AqueousMolecule) -> BalancedReactionEquation {
        BalancedReactionEquation(
            coefficients: coefficients,
            equilibriumConstant: equilibriumTime,
            initialConcentrations: initialConcentrations.updating(with: newValue, for: molecule),
            startTime: startTime,
            equilibriumTime: equilibriumTime,
            previous: nil
        )
    }
}

