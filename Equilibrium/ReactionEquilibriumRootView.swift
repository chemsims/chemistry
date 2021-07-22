//
// Reactions App
//

import SwiftUI
import ReactionsCore

public struct ReactionEquilibriumRootView: View {

    public init(model: RootNavigationViewModel<EquilibriumNavInjector>) {
        self.model = model
    }

    @ObservedObject var model: RootNavigationViewModel<EquilibriumNavInjector>

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public var body: some View {
        GeometryReader { geo in
            makeView(
                settings: EquilibriumAppLayoutSettings(
                    geometry: geo,
                    verticalSizeClass: verticalSizeClass,
                    horizontalSizeClass: horizontalSizeClass
                )
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
