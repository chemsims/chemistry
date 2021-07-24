//
// Reactions App
//

import SwiftUI
import ReactionsCore
import StoreKit

struct UnitCard: View {

    let unit: UnitWithState
    let buyUnit: () -> Void
    let canMakePurchase: Bool
    let layout: APChemLayoutSettings

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                image

                VStack(alignment: .leading, spacing: layout.cardTextVerticalSpacing) {
                    Text(unit.unit.info.title)
                        .font(.title)
                    Text(unit.unit.info.description)
                }
                Spacer(minLength: 0)
            }

            if unit.state != .purchased {
                buyButton
                if !canMakePurchase {
                    iapUnavailableWarning
                }
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

    private var iapUnavailableWarning: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
            Text("In-app purchases are not currently available.")
        }
        .font(.system(.subheadline))
    }

    private var image: some View {
        Image(unit.unit.info.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .mask(RoundedRectangle(cornerRadius: layout.cardIconCornerRadius))
            .frame(square: layout.cardIconSize)
    }
}

// MARK: - Buy button
extension UnitCard {

    private var buyButton: some View {
        BuyButton(
            cornerRadius: layout.cardCornerRadius,
            sideColor: buyButtonBorderColor,
            faceColor: buyButtonColor,
            text: buyButtonString,
            action: buyUnit
        )
        .foregroundColor(buyButtonFontColor)
        .frame(height: 0.5 * layout.cardIconSize)
        .compositingGroup()
        .opacity(buyButtonLoading || !canMakePurchase ? 0.5 : 1)
        .disabled(!isActive || !canMakePurchase)
    }

    private var isActive: Bool {
        switch unit.state {
        case .readyForPurchase, .failedToLoadProduct: return true
        default: return false
        }
    }

    private var buyButtonFontColor: Color {
        if buyButtonError {
            return .buyButtonErrorFont
        }
        return .buyButtonFont
    }


    private var buyButtonColor: Color {
        if buyButtonError {
            return .buyButtonErrorBackground
        }
        return .buyButtonBackground
    }

    private var buyButtonBorderColor: Color {
        if buyButtonError {
            return .buyButtonErrorBorder
        }
        return .buyButtonBorder
    }

    private var buyButtonLoading: Bool {
        switch unit.state {
        case .deferred, .loadingProduct, .purchasing:
            return true
        default: return false
        }
    }

    private var buyButtonError: Bool {
        unit.state == .failedToLoadProduct
    }

    private var buyButtonString: String {
        switch unit.state {
        case .deferred: return "Awaiting approval..."
        case .purchasing: return "Unlocking..."
        case .loadingProduct: return "Connecting to store..."
        case .failedToLoadProduct: return "Cannot connect to store"
        case let .readyForPurchase(product):
            let price = product.regularPrice.map {
                " for \($0)"
            } ?? ""

            return "Unlock now\(price)"
        default: return ""
        }
    }


}

struct UnitCard_Previews: PreviewProvider {

    static var previews: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 25) {
                    card(geo, .reactionRates, .loadingProduct)
                    card(geo, .equilibrium, .readyForPurchase(product: product))
                    card(geo, .reactionRates, .deferred)
                    card(geo, .reactionRates, .purchasing)
                    card(geo, .reactionRates, .failedToLoadProduct)
                    card(geo, .reactionRates, .purchased)

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
        _ unit: Unit,
        _ state: PurchaseState
    ) -> some View {
        UnitCard(
            unit: UnitWithState(
                unit: unit,
                state: state
            ),
            buyUnit: { },
            canMakePurchase: false,
            layout: .init(
                geometry: geo,
                verticalSizeClass: nil,
                horizontalSizeClass: nil
            )
        )
    }
}
