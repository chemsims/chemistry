//
// Reactions App
//

import SwiftUI

struct UnitSelection: View {

    let units: [Unit]
    @ObservedObject var model: APChemRootNavigationModel
    let layout: APChemLayoutSettings

    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                VStack(spacing: layout.cardVerticalSpacing) {
                    HStack {
                        Button(action: {
                                model.showUnitSelection = false
                        }) {
                            Text("Back")
                        }
                        Spacer(minLength: 0)
                    }
                    Text("Choose a unit")
                        .font(.largeTitle)

                    ForEach(units) { unit in
                        UnitCard(
                            unit: unit.info,
                            layout: layout
                        )
                        .onTapGesture {
                            model.goTo(unit: unit)
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
                units: Unit.all,
                model: APChemRootNavigationModel(),
                layout: .init(
                    geometry: geo,
                    verticalSizeClass: nil,
                    horizontalSizeClass: nil
                )
            )
        }
    }
}
