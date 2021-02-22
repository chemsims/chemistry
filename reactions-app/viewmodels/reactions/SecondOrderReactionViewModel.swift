//
// Reactions App
//

import CoreGraphics

class SecondOrderReactionViewModel: ZeroOrderReactionViewModel {

    var inverseAEquation: Equation? {
        input.concentrationA.map { InverseEquation(underlying: $0) }
    }
}
