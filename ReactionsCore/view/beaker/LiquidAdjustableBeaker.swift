//
// ReactionsApp
//

import SwiftUI

struct LiquidAdjustableBeaker: View {

    let moleculesA: [GridCoordinate]
    let concentrationB: Equation?
    let currentTime: CGFloat?
    let reactionPair: ReactionPairDisplay   

    var body: some View {
        FilledBeaker(
            moleculesA: moleculesA,
            concentrationB: concentrationB,
            currentTime: currentTime,
            reactionPair: reactionPair,
            rows: 8.4
        )
    }
}

struct LiquidAdjustableBeaker_Previews: PreviewProvider {
    static var previews: some View {
        LiquidAdjustableBeaker(
            moleculesA: [],
            concentrationB: nil,
            currentTime: nil,
            reactionPair: ReactionType.A.display
        )
    }
}
