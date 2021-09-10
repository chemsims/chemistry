//
// Reactions App
//

import SwiftUI
import ReactionsCore

public struct ChemicalReactionsRootView: View {

    public init(
        model: RootNavigationViewModel<ChemicalReactionsAppNavInjector>,
        unitSelectionIsShowing: Binding<Bool>,
        aboutPageIsShowing: Binding<Bool>
    ) {
        self.model = model
        self._unitSelectionIsShowing = unitSelectionIsShowing
        self._aboutPageIsShowing = aboutPageIsShowing
    }

    @ObservedObject var model: RootNavigationViewModel<ChemicalReactionsAppNavInjector>
    @Binding var unitSelectionIsShowing: Bool
    @Binding var aboutPageIsShowing: Bool

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public var body: some View {
        GeometryReader { geo in
            makeView(
                layout: .init(
                    geometry: geo,
                    verticalSizeClass: verticalSizeClass,
                    horizontalSizeClass: horizontalSizeClass
                )
            )
        }
    }

    private func makeView(layout: ChemicalReactionsScreenLayout) -> some View {
        GeneralRootNavigationView(
            model: model,
            navigationRows: ChemicalReactionNavigationRows.rows,
            menuIconSize: layout.menuSize,
            menuTopPadding: layout.menuTopPadding,
            menuHPadding: layout.menuHPadding,
            unitSelectionIsShowing: $unitSelectionIsShowing,
            aboutPageIsShowing: $aboutPageIsShowing
        )
    }
}

extension ChemicalReactionsScreenLayout {
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
