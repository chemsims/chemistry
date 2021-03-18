//
// Reactions App
//

import ReactionsCore
import CoreGraphics

struct ScalesRotationEquation: Equation {

    let reaction: NewBalancedReactionEquation
    let maxAngle: CGFloat

    func getY(at x: CGFloat) -> CGFloat {
        let quotientEquation = ReactionQuotientEquation(equations: reaction)
        let quotient = quotientEquation.getY(at: x)
        let convergedQuotient = quotientEquation.getY(at: reaction.equilibriumTime)
        let quotientFactor = convergedQuotient == 0 ? 0 : quotient / convergedQuotient

        if reaction.isForward {
            let reactantSum = reaction.initialConcentrations.reactantA + reaction.initialConcentrations.reactantB
            let sumFactor = reactantSum / AqueousReactionSettings.Scales.concentrationSumAtMaxScaleRotation
            let initAngle = min(sumFactor * maxAngle, maxAngle)

            return -initAngle * (1 - quotientFactor)
        }

        let tAddProd = AqueousReactionSettings.timeToAddProduct
        let c0 = reaction.concentration.productC.getY(at: tAddProd)
        let t0 = reaction.concentration.productD.getY(at: tAddProd)

        let productFactor = (c0 + t0) / AqueousReactionSettings.Scales.concentrationSumAtMaxScaleRotation
        let initAngle = min(productFactor * maxAngle, maxAngle)

        let maxQuotient = quotientEquation.getY(at: tAddProd)
        if (abs(convergedQuotient - maxQuotient) < 0.001) {
            return 0
        }
        let factor = (quotient - convergedQuotient) / (maxQuotient - convergedQuotient)
        return min(initAngle * factor, maxAngle)
    }
}
