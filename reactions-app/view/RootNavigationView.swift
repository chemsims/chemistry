//
// Reactions App
//
  

import SwiftUI

struct RootNavigationView: View {

    @ObservedObject var model: RootNavigationViewModel

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            makeView(
                settings: OrderedReactionLayoutSettings(
                    geometry: geometry,
                    horizontalSize: horizontalSizeClass,
                    verticalSize: verticalSizeClass
                )
            )
        }
    }

    private func makeView(settings: OrderedReactionLayoutSettings) -> some View {
        ZStack {
            model.view
                .id(model.currentScreen)
                .transition(
                    .asymmetric(
                        insertion: .move(
                            edge: model.navigationDirection == .forward ? .trailing : .leading
                        ),
                        removal: AnyTransition.move(
                            edge: model.navigationDirection == .forward ? .leading : .trailing
                        ).combined(with: .opacity)
                    )
                )

            MainMenuOverlay(
                size: settings.menuSize,
                topPadding: settings.menuTopPadding,
                menuHPadding: settings.menuHPadding,
                navigation: model
            )
        }
    }
}



struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        // iPhone SEo
        RootNavigationView(
            model: RootNavigationViewModel(
                persistence: InMemoryReactionInputPersistence()
            )
        ).previewLayout(.fixed(width: 568, height: 320))

        // iPad mini
        RootNavigationView(
            model: RootNavigationViewModel(
                persistence: InMemoryReactionInputPersistence()
            )
        ).previewLayout(.fixed(width: 1024, height: 768))

        // iPad Pro 11
        RootNavigationView(
            model: RootNavigationViewModel(
                persistence: InMemoryReactionInputPersistence()
            )
        ).previewLayout(.fixed(width: 1194, height: 834))
    }
}
