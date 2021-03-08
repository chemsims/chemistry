//
// Reactions App
//

import CoreGraphics
import ReactionsCore

struct BeakerMoleculesSetter {

    let totalMolecules: Int
    let endOfReactionTime: CGFloat
    let moleculesA: [GridCoordinate]
    let moleculesB: [GridCoordinate]
    let reactionEquation: BalancedReactionEquations

    var cMolecules: [GridCoordinate] {
        guard moleculesA.count > 0 && moleculesB.count > 0 else {
            return []
        }
        return Array(moleculesA.prefix(cToTakeFromA) + moleculesB.prefix(cToTakeFromB))
    }

    var dMolecules: [GridCoordinate] {
        guard moleculesA.count > 0 && moleculesB.count > 0 else {
            return []
        }
        let fromA = moleculesA.dropFirst(cToTakeFromA).prefix(dToTakeFromA)
        let fromB = moleculesB.dropFirst(cToTakeFromB).prefix(dToTakeFromB)
        return Array(fromA + fromB)
    }

    var cFractionToDraw: Equation {
        fractionToDrawEquation(reactionEquation.productC)
    }

    var dFractionToDraw: Equation {
        fractionToDrawEquation(reactionEquation.productD)
    }

    private func fractionToDrawEquation(_ underlying: Equation) -> Equation {
        ScaledEquation(
            targetY: 1,
            targetX: endOfReactionTime,
            underlying: underlying
        )
    }

    private var numDToAdd: Int {
        let finalConcentration = reactionEquation.productD.getY(at: endOfReactionTime)
        return (finalConcentration * CGFloat(totalMolecules)).roundedInt()
    }

    private var numCToAdd: Int {
        let finalConcentration = reactionEquation.productC.getY(at: endOfReactionTime)
        return (finalConcentration * CGFloat(totalMolecules)).roundedInt()
    }

    private var fractionFromA: CGFloat {
        let aBSum = moleculesA.count + moleculesB.count
        assert(aBSum != 0)
        return CGFloat(moleculesA.count) / CGFloat(aBSum)
    }

    private var cToTakeFromA: Int {
        min(0, Int(ceil(Double(numAToDrop) / 2)))
    }

    private var dToTakeFromA: Int {
        min(0, Int(floor((Double(numAToDrop) / 2))))
    }

    private var cToTakeFromB: Int {
        numCToAdd - cToTakeFromA
    }

    private var dToTakeFromB: Int {
        numDToAdd - dToTakeFromA
    }

    private var numAToDrop: Int {
        let finalConcentration = reactionEquation.reactantA.getY(at: endOfReactionTime)
        return (finalConcentration * CGFloat(totalMolecules)).roundedInt()
    }
}
