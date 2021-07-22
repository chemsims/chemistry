//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct UnitCard: View {

    let unit: UnitInfo
    let layout: APChemLayoutSettings

    var body: some View {
        HStack(alignment: .top) {
            image

            VStack(alignment: .leading, spacing: layout.cardTextVerticalSpacing) {
                Text(unit.title)
                    .font(.title)
                Text(unit.description)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .frame(width: layout.unitCardWidth)
        .background(
            RoundedRectangle(cornerRadius: layout.cardCornerRadius)
                .foregroundColor(.white)
                .shadow(radius: layout.cardShadowRadius)
        )
    }

    private var image: some View {
        Image(unit.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .mask(RoundedRectangle(cornerRadius: layout.cardIconCornerRadius))
            .frame(square: layout.cardIconSize)
    }
}


struct UnitCard_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            VStack(spacing: 25) {
                UnitCard(
                    unit: Unit.reactionRates.info,
                    layout: .init(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                )

                UnitCard(
                    unit: Unit.equilibrium.info,
                    layout: .init(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                )
            }
        }
        .previewLayout(.iPhoneSELandscape)
    }
}
