//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ReactionEquilibriumRootView: View {
    @ObservedObject var model: RootNavigationViewModel<AnyNavigationInjector<EquilibriumAppScreen>>

    var body: some View {
        GeometryReader { geo in
            makeView(
                settings: AqueousScreenLayoutSettings(geometry: geo)
            )
        }
    }

    private func makeView(settings: AqueousScreenLayoutSettings) -> some View {
        GeneralRootNavigationView(
            model: model,
            navigationRows: ReactionEquilibriumNavigationRows.rows,
            feedbackSettings: .reactionEquilibrium,
            shareSettings: .reactionEquilibrium,
            menuIconSize: settings.menuSize,
            menuTopPadding: settings.menuTopPadding,
            menuHPadding: settings.menuHPadding
        )
    }
}

extension AqueousScreenLayoutSettings {
    var menuSize: CGFloat {
        0.03 * width
    }

    var menuHPadding: CGFloat {
        0.5 * menuSize
    }

    var menuTopPadding: CGFloat {
        0.5 * menuSize
    }
}
