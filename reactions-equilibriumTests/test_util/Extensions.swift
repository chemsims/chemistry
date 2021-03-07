//
// Reactions App
//

import Foundation
import CoreGraphics
@testable import reactions_equilibrium

extension BalancedReactionCoefficients {
    static let unit = BalancedReactionCoefficients(reactantA: 1, reactantB: 1, productC: 1, productD: 1)
}

extension BalancedReactionEquations {
    func withA0(_ newValue: CGFloat) -> BalancedReactionEquations {
        with(a0: newValue, b0: b0)
    }

    func withB0(_ newValue: CGFloat) -> BalancedReactionEquations {
        with(a0: a0, b0: newValue)
    }

    private func with(a0: CGFloat, b0: CGFloat) -> BalancedReactionEquations {
        BalancedReactionEquations(
            coefficients: coefficients,
            equilibriumConstant: equilibriumConstant,
            a0: a0,
            b0: b0,
            convergenceTime: convergenceTime
        )
    }
}
