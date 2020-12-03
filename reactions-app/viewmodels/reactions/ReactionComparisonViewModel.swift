//
// Reactions App
//
  

import CoreGraphics

class ReactionComparisonViewModel: ZeroOrderReactionViewModel {

    let zeroOrderInput: ReactionInput
    let firstOrderInput: ReactionInput
    let secondOrderInput: ReactionInput

    init(
        persistence: ReactionInputPersistence
    ) {
        let defaultInput = ReactionInput(
            c1: ReactionComparisonDefaults.c1,
            c2: ReactionComparisonDefaults.c2,
            t1: 0,
            t2: ReactionComparisonDefaults.time
        )
        self.zeroOrderInput = persistence.get(order: .Zero) ?? defaultInput
        self.firstOrderInput = persistence.get(order: .First) ?? defaultInput
        self.secondOrderInput = persistence.get(order: .Second) ?? defaultInput

        let maxTime = [zeroOrderInput.t2, firstOrderInput.t2, secondOrderInput.t2].max()!

        super.init()
        self.initialTime = 0
        self.initialConcentration = 1
        self.finalTime = maxTime
    }

    var zeroOrder: ConcentrationEquation {
        let equation = LinearConcentration(
            t1: zeroOrderInput.t1,
            c1: zeroOrderInput.c1,
            t2: zeroOrderInput.t2,
            c2: zeroOrderInput.c2
        )
        return LimitedEquation(underlying: equation, input: zeroOrderInput)
    }

    var firstOrder: ConcentrationEquation {
        let equation = FirstOrderConcentration(c1: firstOrderInput.c1, c2: firstOrderInput.c2, time: firstOrderInput.t2)
        return LimitedEquation(underlying: equation, input: firstOrderInput)
    }

    var secondOrder: ConcentrationEquation {
        let equation = SecondOrderReactionEquation(c1: secondOrderInput.c1, c2: secondOrderInput.c2, time: secondOrderInput.t2)
        return LimitedEquation(underlying: equation, input: secondOrderInput)
    }

    func aMolecules(concentration: CGFloat) -> [GridCoordinate] {
        let numToTake = Int(CGFloat(moleculesA.count) * concentration)
        return Array(moleculesA.prefix(numToTake))
    }

}

struct ReactionComparisonDefaults {
    static let c1: CGFloat = 1
    static let c2: CGFloat = 0.1
    static let time: CGFloat = 15
}

fileprivate struct LimitedEquation: ConcentrationEquation {

    let underlying: ConcentrationEquation
    let input: ReactionInput

    func getConcentration(at time: CGFloat) -> CGFloat {
        let minTime = input.t1
        let maxTime = input.t2
        let adjustedTime = min(maxTime, max(time, minTime))
        return underlying.getConcentration(at: adjustedTime)
    }

}


