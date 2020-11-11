//
// Reactions App
//
  

import SwiftUI

struct ZeroOrderReaction: View {

    @ObservedObject var moleculeConcentration: MoleculeContentrationViewModel

    var body: some View {
        VStack {
            CustomSlider(
                value: $moleculeConcentration.concentration,
                minValue: 0.1,
                maxValue: 0.9,
                handleThickness: 25,
                handleColor: Color.orangeAccent,
                handleCornerRadius: 5,
                barThickness: 4,
                barColor: Color.darkGray,
                leadingPadding: 10,
                trailingPadding: 10,
                orientation: .portrait
            ).frame(width: 55, height: 200)

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
