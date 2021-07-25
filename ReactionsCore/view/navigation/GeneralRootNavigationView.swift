//
// Reactions App
//

import SwiftUI

public struct GeneralRootNavigationView<Injector: NavigationInjector>: View {

    @ObservedObject var model: RootNavigationViewModel<Injector>
    let navigationRows: NavigationRows<Injector.Screen>
    let feedbackSettings: FeedbackSettings
    let shareSettings: ShareSettings
    let menuIconSize: CGFloat
    let menuTopPadding: CGFloat
    let menuHPadding: CGFloat
    @Binding var unitSelectionIsShowing: Bool

    public init(
        model: RootNavigationViewModel<Injector>,
        navigationRows: NavigationRows<Injector.Screen>,
        feedbackSettings: FeedbackSettings,
        shareSettings: ShareSettings,
        menuIconSize: CGFloat,
        menuTopPadding: CGFloat,
        menuHPadding: CGFloat,
        unitSelectionIsShowing: Binding<Bool>
    ) {
        self.model = model
        self.navigationRows = navigationRows
        self.feedbackSettings = feedbackSettings
        self.shareSettings = shareSettings
        self.menuIconSize = menuIconSize
        self.menuTopPadding = menuTopPadding
        self.menuHPadding = menuHPadding
        self._unitSelectionIsShowing = unitSelectionIsShowing
    }

    public var body: some View {
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
                .accessibility(hidden: model.showMenu)
                .disabled(model.showAnalyticsConsent)

            MainMenuOverlay(
                rows: navigationRows,
                navigation: model,
                feedbackSettings: feedbackSettings,
                shareSettings: shareSettings,
                size: menuIconSize,
                topPadding: menuTopPadding,
                menuHPadding: menuHPadding,
                unitSelectionIsShowing: $unitSelectionIsShowing
            )
        }
    }
}
