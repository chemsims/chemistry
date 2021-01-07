//
// Reactions App
//
  

import CoreGraphics

class SecondOrderReactionViewModel: ZeroOrderReactionViewModel {

    override func generateEquation(
        c1: CGFloat,
        c2: CGFloat,
        t1: CGFloat,
        t2: CGFloat
    ) -> ConcentrationEquation {
        return SecondOrderConcentration(
            c1: c1,
            c2: c2,
            time: t2
        )
    }

    var inverseAEquation: Equation? {
        input.concentrationA.map { InverseEquation(underlying: $0) }
    }
}
