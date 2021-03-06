//
// Reactions App
//

import Foundation
import CoreGraphics

public struct NonLinearEquationSolver {

    /// Returns an x value for which an equation returns a target y, within some tolerance, or nil if no such x was found
    /// - Parameters:
    ///     - targetY: The Y value which the equation should return
    ///     - equation: The equation which should be adjusted
    ///     - tolerance: The tolerance to accept for target Y values
    ///     - minInput: The minimum x input to check for a solution, exclusive
    ///     - maxInput: The maximum x input to check for a solution, exclusive
    public static func findXFor(
        targetY: CGFloat,
        in equation: Equation,
        tolerance: CGFloat,
        minInput: CGFloat,
        maxInput: CGFloat
    ) -> CGFloat? {
        return nil
    }
}


