//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderReaction: View {

    @ObservedObject var moleculeConcentration: ReactionViewModel

    var body: some View {
        VStack {
            TimeChartAxisView(
                concentration: $moleculeConcentration.concentration,
                time: $moleculeConcentration.initialTime,
                minConcentration: ReactionSettings.minConcentration,
                maxConcentration: ReactionSettings.maxConcentration,
                minTime: ReactionSettings.minTime,
                maxTime: ReactionSettings.maxTime
            )

            FilledBeaker(molecules: [(Styling.moleculeA, moleculeConcentration.molecules)])
                .frame(width: 350, height: 420)
        }
    }
}

struct ZeroOrderReaction_Previews: PreviewProvider {
    static var previews: some View {
        ZeroOrderReaction(
            moleculeConcentration: ReactionViewModel()
        )
    }
}
