//
// Reactions App
//

import Foundation
import CoreGraphics

struct GaseousReactionSettings {
    static let minRows = 5
    static let maxRows = 15
    static let initialRows = (minRows + maxRows) / 2

    static let minRowDelta = 2
    static let minHeatDelta: CGFloat = 0.2

    static let forwardTiming = ReactionTiming.standard(reactionIndex: 0)
    static let pressureTiming = ReactionTiming.standard(reactionIndex: 1)
    static let heatTiming = ReactionTiming.standard(reactionIndex: 2)

    static let pressureToConcentration: CGFloat = 5

    static func pressureConstantFromConcentrationConstant(
        _ k: CGFloat,
        coefficients: MoleculeValue<Int>
    ) -> CGFloat {
        let productCoeffs = coefficients.productC + coefficients.productD
        let reactantCoeffs = coefficients.reactantA + coefficients.reactantB
        let factor = pow(GaseousReactionSettings.pressureToConcentration, CGFloat(productCoeffs - reactantCoeffs))
        return k * factor
    }
}

