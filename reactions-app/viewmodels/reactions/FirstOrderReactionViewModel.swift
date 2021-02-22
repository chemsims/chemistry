//
// Reactions App
//

import SwiftUI

class FirstOrderReactionViewModel: ZeroOrderReactionViewModel {

    var logAEquation: Equation? {
        input.concentrationA.map { LogEquation(underlying: $0) }
    }

}
