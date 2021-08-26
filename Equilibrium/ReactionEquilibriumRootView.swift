//
// Reactions App
//

import SwiftUI
import ReactionsCore

public struct ReactionEquilibriumRootView: View {

    public init(
        model: RootNavigationViewModel<EquilibriumNavInjector>,
        unitSelectionIsShowing: Binding<Bool>,
        aboutPageIsShowing: Binding<Bool>
    ) {
        self.model = model
        self._unitSelectionIsShowing = unitSelectionIsShowing
        self._aboutPageIsShowing = aboutPageIsShowing
    }

    @ObservedObject var model: RootNavigationViewModel<EquilibriumNavInjector>
    @Binding var unitSelectionIsShowing: Bool
    @Binding var aboutPageIsShowing: Bool

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
            menuIconSize: settings.menuSize,
            menuTopPadding: settings.menuTopPadding,
            menuHPadding: settings.menuHPadding,
            unitSelectionIsShowing: $unitSelectionIsShowing,
            aboutPageIsShowing: $aboutPageIsShowing
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
