//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ReactionEquilibriumRootView: View {
    @ObservedObject var model: RootNavigationViewModel<AnyNavigationInjector<EquilibriumAppScreen, EquilibriumQuestionSet>>
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        GeometryReader { geo in
            makeView(
                settings: EquilibriumAppLayoutSettings(geometry: geo, verticalSizeClass: verticalSizeClass)
            )
        }
    }

    private func makeView(settings: EquilibriumAppLayoutSettings) -> some View {
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

extension EquilibriumAppLayoutSettings {
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
