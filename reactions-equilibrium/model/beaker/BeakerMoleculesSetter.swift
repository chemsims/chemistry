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
        max(0, Int(ceil(Double(numAToDrop) / 2)))
    }

    private var dToTakeFromA: Int {
        max(0, Int(floor((Double(numAToDrop) / 2))))
    }

    private var cToTakeFromB: Int {
        max(0, numCToAdd - cToTakeFromA)
    }

    private var dToTakeFromB: Int {
        max(0, numDToAdd - dToTakeFromA)
    }

    private var numAToDrop: Int {
        let finalConcentration = reactionEquation.reactantA.getY(at: endOfReactionTime)
        return (finalConcentration * CGFloat(totalMolecules)).roundedInt()
    }
}

struct ReverseBeakerMoleculeSetter {

    let totalMolecules: Int
    let reaction: BalancedReactionEquations
    let startTime: CGFloat
    let cMolecules: [GridCoordinate]
    let dMolecules: [GridCoordinate]
    let originalAMolecules: [GridCoordinate]
    let originalBMolecules: [GridCoordinate]

    init(
        reverseReaction: BalancedReactionEquations,
        startTime: CGFloat,
        forwardBeaker: BeakerMoleculesSetter,
        cMolecules: [GridCoordinate],
        dMolecules: [GridCoordinate]
    ) {
        self.totalMolecules = forwardBeaker.totalMolecules
        self.reaction = reverseReaction
        self.startTime = startTime
        self.cMolecules = cMolecules
        self.dMolecules = dMolecules

        self.originalAMolecules = Self.initialReactantGrid(
            forwardCoords: forwardBeaker.moleculesA,
            forwardMolecules: forwardBeaker
        )

        self.originalBMolecules = Self.initialReactantGrid(
            forwardCoords: forwardBeaker.moleculesB,
            forwardMolecules: forwardBeaker
        )
    }

    var aMolecules: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: aCoords,
            fractionToDraw: reactantFractionToDraw(equation: reaction.reactantA, coordCount: aCoords.count)
        )
    }

    var bMolecules: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: bCoords, 
            fractionToDraw: reactantFractionToDraw(equation: reaction.reactantB, coordCount: bCoords.count)
        )
    }

    private var aCoords: [GridCoordinate] {
        let fromC = Array(cMolecules.prefix(aToTakeFromC))
        let fromD = Array(dMolecules.prefix(aToTakeFromD))
        return originalAMolecules + fromC + fromD
    }

    private var bCoords: [GridCoordinate] {
        let fromC = Array(cMolecules.dropFirst(aToTakeFromC).prefix(bToTakeFromC))
        let fromD = Array(dMolecules.dropFirst(aToTakeFromD).prefix(bToTakeFromD))
        return originalBMolecules + fromC + fromD
    }

    private func reactantFractionToDraw(equation: Equation, coordCount: Int) -> Equation {
        MoleculeGridFractionToDraw(
            underlyingConcentration: equation,
            initialConcentration: equation.getY(at: startTime),
            finalConcentration: equation.getY(at: reaction.convergenceTime),
            gridCount: coordCount,
            totalGridCount: totalMolecules
        )
    }

    private var aToTakeFromC: Int {
        let result = Int(ceil(Double(numCToDrop) / 2))
        return max(0, min(result, numAToAdd))
    }

    private var aToTakeFromD: Int {
        numAToAdd - aToTakeFromC
    }

    private var bToTakeFromC: Int {
        let result = Int(floor(Double(numCToDrop) / 2))
        return max(0, min(result, numBToAdd))
    }

    private var bToTakeFromD: Int {
        numBToAdd - bToTakeFromC
    }

    private var numAToAdd: Int {
        productToAdd(equation: reaction.reactantA)
    }

    private var numBToAdd: Int {
        productToAdd(equation: reaction.reactantB)
    }

    private var numCToDrop: Int {
        reactantToDrop(equation: reaction.productC)
    }

    private func productToAdd(equation: Equation) -> Int {
        let final = finalCount(equation: equation)
        let initial = initialCount(equation: equation)
        assert(final >= initial)
        return final - initial
    }

    private func reactantToDrop(equation: Equation) -> Int {
        let final = finalCount(equation: equation)
        let initial = initialCount(equation: equation)
        assert(initial >= final)
        return initial - final
    }

    private func finalCount(equation: Equation) -> Int {
        let finalConcentration = equation.getY(at: reaction.convergenceTime)
        return GridMoleculesUtil.gridCount(for: finalConcentration, gridSize: totalMolecules)
    }

    private func initialCount(equation: Equation) -> Int {
        let startingConcentration = equation.getY(at: startTime)
        return GridMoleculesUtil.gridCount(for: startingConcentration, gridSize: totalMolecules)
    }

    private static func initialReactantGrid(
        forwardCoords: [GridCoordinate],
        forwardMolecules: BeakerMoleculesSetter
    ) -> [GridCoordinate] {
        let products = forwardMolecules.cMolecules + forwardMolecules.dMolecules
        return forwardCoords.filter { coord in
            !products.contains(coord)
        }
    }
}
