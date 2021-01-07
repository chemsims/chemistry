//
// Reactions App
//
  

import SwiftUI

class FirstOrderReactionViewModel: ZeroOrderReactionViewModel {

    override func generateEquation(
        c1: CGFloat,
        c2: CGFloat,
        t1: CGFloat,
        t2: CGFloat
    ) -> ConcentrationEquation {
        FirstOrderConcentration(
            c1: c1,
            c2: c2,
            time: t2
        )
    }

    var logAEquation: Equation? {
        input.concentrationA.map { LogEquation(underlying: $0) }
    }

}
