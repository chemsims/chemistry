//
// Reactions App
//

import SwiftUI
import ReactionsCore
import StoreKit

struct UnitCard: View {

    let unit: Unit
    let layout: APChemLayoutSettings

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                image

                VStack(alignment: .leading, spacing: layout.cardTextVerticalSpacing) {
                    Text(unit.info.title)
                        .font(.title)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(unit.info.description)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
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
        Image(unit.info.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .mask(RoundedRectangle(cornerRadius: layout.cardIconCornerRadius))
            .frame(square: layout.cardIconSize)
    }
}

struct UnitCard_Previews: PreviewProvider {

    static var previews: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 25) {
                    card(geo, .reactionRates)
                    card(geo, .equilibrium)
                    card(geo, .acidsBases)

                }
                .frame(width: geo.size.width)
                .padding()
            }
        }
        .frame(width: 400)
        .previewLayout(.sizeThatFits)
    }

    static let product: SKProduct = {
        let p = SKProduct()
        p.setValue(NSDecimalNumber(1.99), forKey: "price")
        p.setValue("id", forKey: "productIdentifier")
        p.setValue(Locale(identifier: "en_us"), forKey: "priceLocale")
        return p
    }()

    static func card(
        _ geo: GeometryProxy,
        _ unit: Unit
    ) -> some View {
        UnitCard(
            unit: unit,
            layout: .init(
                geometry: geo,
                verticalSizeClass: nil,
                horizontalSizeClass: nil
            )
        )
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
    }
}
