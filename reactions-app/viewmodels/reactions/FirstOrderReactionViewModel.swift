//
// Reactions App
//

import SwiftUI
import ReactionsCore

class FirstOrderReactionViewModel: ZeroOrderReactionViewModel {

    var logAEquation: Equation? {
        input.concentrationA.map { LogEquation(underlying: $0) }
    }

}
