//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct UnitSelection: View {

    @ObservedObject var navigation: APChemRootNavigationModel
    let layout: APChemLayoutSettings

    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                VStack(spacing: 0.2 * layout.cardVerticalSpacing) {
                    backButton
                    title

                    VStack(spacing: layout.cardVerticalSpacing) {
                        units
                    }
                    .padding(.vertical, layout.cardVerticalSpacing)
                }
                Spacer()
            }
            .padding(.vertical, layout.unitSelectionVerticalPadding)
        }
    }

    private var backButton: some View {
        HStack {
            Button(action: {
                    navigation.activeSheet = nil
            }) {
                Text("Back")
                    .accessibility(hint: Text("Closes unit selection page"))
            }
            Spacer(minLength: 0)
        }
    }

    private var title: some View {
        Text("Choose a unit")
            .font(.largeTitle.bold())
            .foregroundColor(.primaryDarkBlue)
            .accessibility(addTraits: .isHeader)
    }

    private var units: some View {
        ForEach(Unit.available) { unit in
            UnitCard(
                unit: unit,
                layout: layout
            )
            .accessibilityElement(children: .contain)
            .accessibility(hint: Text("Opens \(unit.info.title) unit"))
            .accessibility(addTraits: .isButton)
            .onTapGesture {
                navigation.goTo(unit: unit)
            }
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

    var unitSelectionVerticalPadding: CGFloat {
        cardTextVerticalSpacing
    }

    var cardLockSize: CGFloat {
        0.3 * cardIconSize
    }

    var cardOffset: CGSize {
        CGSize(
            width: 0.4 * cardLockSize,
            height: -0.2 * cardLockSize
        )
    }
}

struct UnitSelection_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            UnitSelection(
                navigation: APChemRootNavigationModel(
                    injector: DebugAPChemInjector(),
                    tipOverlayModel: .init(
                        persistence: UserDefaultsTipOverlayPersistence(),
                        locker: InMemoryProductLocker(),
                        analytics: NoOpGeneralAnalytics()
                    )
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
