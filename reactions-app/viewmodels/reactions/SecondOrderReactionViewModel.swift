//
// Reactions App
//

import CoreGraphics
import ReactionsCore

class SecondOrderReactionViewModel: ZeroOrderReactionViewModel {

    var inverseAEquation: Equation? {
        input.concentrationA.map { InverseEquation(underlying: $0) }
    }
}
