//
// Reactions App
//
  

import CoreGraphics

class ReactionComparisonViewModel: ZeroOrderReactionViewModel {

    override init() {
        super.init()
        self.initialTime = 0
        self.finalTime = 17
    }

    var zeroOrderInput: ReactionInput = ReactionInput(
        c1: 1,
        c2: 0.1,
        t1: 5,
        t2: 11
    )
    var zeroOrder: ConcentrationEquation {
        let equation = LinearConcentration(
            t1: zeroOrderInput.t1,
            c1: zeroOrderInput.c1,
            t2: zeroOrderInput.t2,
            c2: zeroOrderInput.c2
        )
        return LimitedEquation(underlying: equation, input: zeroOrderInput)
    }

    var firstOrderInput = ReactionInput(
        c1: 0.8,
        c2: 0.2,
        t1: 0,
        t2: 8
    )
    var firstOrder: ConcentrationEquation {
        let equation = SecondOrderReactionEquation(c1: firstOrderInput.c1, c2: firstOrderInput.c2, time: firstOrderInput.t2)
        return LimitedEquation(underlying: equation, input: firstOrderInput)
    }

    var secondOrderInput = ReactionInput(
        c1: 0.5,
        c2: 0.2,
        t1: 0,
        t2: 17
    )
    var secondOrder: ConcentrationEquation {
        let equation = SecondOrderReactionEquation(c1: secondOrderInput.c1, c2: secondOrderInput.c2, time: secondOrderInput.t2)
        return LimitedEquation(underlying: equation, input: secondOrderInput)
    }

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

struct ReactionInput {
    let c1: CGFloat
    let c2: CGFloat
    let t1: CGFloat
    let t2: CGFloat
}
