//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct RootNavigationView: View {

    @ObservedObject var model: RootNavigationViewModel<AnyNavigationInjector<AppScreen>>

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
        GeneralRootNavigationView(
            model: model,
            navigationRows: ReactionRateNavigationRows.rows,
            feedbackSettings: .reactionsRate,
            shareSettings: .reactionsRate,
            menuIconSize: settings.menuSize,
            menuTopPadding: settings.menuTopPadding,
            menuHPadding: settings.menuHPadding
        )
    }
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        // iPhone SE
        RootNavigationView(
            model: ReactionRateNavigationModel.navigationModel(
                using: InMemoryInjector()
            )
        ).previewLayout(.fixed(width: 568, height: 320))

        // iPad mini
        RootNavigationView(
            model: ReactionRateNavigationModel.navigationModel(
                using: InMemoryInjector()
            )
        ).previewLayout(.fixed(width: 1024, height: 768))

        // iPad Pro 11
        RootNavigationView(
            model: ReactionRateNavigationModel.navigationModel(
                using: InMemoryInjector()
            )
        ).previewLayout(.fixed(width: 1194, height: 834))
    }
}
