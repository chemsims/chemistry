//
// Reactions App
//

import SwiftUI
import ReactionsCore

public struct AcidAppRootView: View {

    public init(
        model: RootNavigationViewModel<AcidAppNavInjector>,
        unitSelectionIsShowing: Binding<Bool>,
        aboutPageIsShowing: Binding<Bool>
    ) {
        self.model = model
        self._unitSelectionIsShowing = unitSelectionIsShowing
        self._aboutPageIsShowing = aboutPageIsShowing
    }

    @ObservedObject var model: RootNavigationViewModel<AcidAppNavInjector>
    @Binding var unitSelectionIsShowing: Bool
    @Binding var aboutPageIsShowing: Bool

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public var body: some View {
        GeometryReader { geo in
            makeView(
                settings: AcidBasesScreenLayout(
                    geometry: geo,
                    verticalSizeClass: verticalSizeClass,
                    horizontalSizeClass: horizontalSizeClass
                )
            )
        }
    }

    private func makeView(settings: AcidBasesScreenLayout) -> some View {
        GeneralRootNavigationView(
            model: model,
            navigationRows: AcidAppNavigationRows.rows,
            menuIconSize: settings.menuSize,
            menuTopPadding: settings.menuTopPadding,
            menuHPadding: settings.menuHPadding,
            unitSelectionIsShowing: $unitSelectionIsShowing,
            aboutPageIsShowing: $aboutPageIsShowing
        )
    }
}

extension AcidBasesScreenLayout {
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


struct AcidAppRootView_Previews: PreviewProvider {
    static var previews: some View {
        AcidAppRootView(
            model: AcidBasesNavigationModel.model(
                injector: InMemoryAcidBasesInjector(),
                sharePrompter: SharePrompter(
                    persistence: InMemorySharePromptPersistence(),
                    appLaunches: InMemoryAppLaunchPersistence(),
                    analytics: NoOpGeneralAnalytics()
                ),
                appLaunchPersistence: InMemoryAppLaunchPersistence(),
                analytics: NoOpGeneralAnalytics()
            ),
            unitSelectionIsShowing: .constant(false),
            aboutPageIsShowing: .constant(false)
        )
        .previewLayout(.iPhoneSELandscape)
    }
}
