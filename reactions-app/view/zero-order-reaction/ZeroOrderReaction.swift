//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderReaction: View {

    @ObservedObject var moleculeConcentration: MoleculeContentrationViewModel

    var body: some View {
        VStack {
            TimeChartAxisView(
                concentration: $moleculeConcentration.concentration,
                time: .constant(0.5)
            )

            FilledBeaker(molecules: [(Styling.moleculeA, moleculeConcentration.molecules)])
                .frame(width: 350, height: 420)
        }
    }
}

struct ZeroOrderReaction_Previews: PreviewProvider {
    static var previews: some View {
        ZeroOrderReaction(
            moleculeConcentration: MoleculeContentrationViewModel()
        )
    }
}
