//
// Reactions App
//

import SwiftUI

struct UnitSelection: View {

    @ObservedObject var navigation: APChemRootNavigationModel
    @ObservedObject var model: StoreManager
    let layout: APChemLayoutSettings

    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                VStack(spacing: layout.cardVerticalSpacing) {
                    HStack {
                        Button(action: {
                                navigation.showUnitSelection = false
                        }) {
                            Text("Back")
                        }
                        Spacer(minLength: 0)
                    }
                    Text("Choose a unit")
                        .font(.largeTitle)

                    ForEach(model.units) { unit in
                        UnitCard(
                            unit: unit,
                            buyUnit: {
                                model.beginPurchase(of: unit)
                            },
                            canMakePurchase: model.canMakePurchase,
                            layout: layout
                        )
                        .onTapGesture {
                            guard unit.state == .purchased else {
                                return
                            }
                            navigation.goTo(unit: unit.unit)
                        }
                    }
                }
                Spacer()
            }
            .padding(.top, layout.unitSelectionTopPadding)
        }
    }
}

struct APChemLayoutSettings {

    let geometry: GeometryProxy
    let verticalSizeClass: UserInterfaceSizeClass?
    let horizontalSizeClass: UserInterfaceSizeClass?

    var width: CGFloat {
        geometry.size.width
    }
    var height: CGFloat {
        geometry.size.height
    }

    var unitCardWidth: CGFloat {
        let maxWidth: CGFloat = 400
        let idealWidth = 0.8 * geometry.size.width
        return min(maxWidth, idealWidth)
    }

    var cardIconSize: CGFloat {
        0.25 * unitCardWidth
    }

    var cardIconCornerRadius: CGFloat {
        0.1 * cardIconSize
    }

    var cardCornerRadius: CGFloat {
        0.5 * cardIconCornerRadius
    }

    var cardShadowRadius: CGFloat {
        0.05 * unitCardWidth
    }

    var cardListHPadding: CGFloat {
        2 * cardShadowRadius
    }

    var cardVerticalSpacing: CGFloat {
        0.2 * cardIconSize
    }

    var cardTextVerticalSpacing: CGFloat {
        0.1 * cardIconSize
    }

    var unitSelectionTopPadding: CGFloat {
        cardTextVerticalSpacing
    }
}

struct UnitSelection_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            UnitSelection(
                navigation: APChemRootNavigationModel(),
                model: StoreManager(
                    locker: InMemoryUnitLocker(),
                    products: DebugProductLoader(),
                    storeObserver: DebugStoreObserver()
                ),
                layout: .init(
                    geometry: geo,
                    verticalSizeClass: nil,
                    horizontalSizeClass: nil
                )
            )
        }
    }
}
