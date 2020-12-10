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

            MainMenuOverlay(
                size: settings.menuSize,
                topPadding: settings.menuTopPadding,
                leadingPadding: settings.menuLeadingPadding,
                navigation: model
            )
        }
    }
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView(model: RootNavigationViewModel(persistence: InMemoryReactionInputPersistence()))
    }
}
