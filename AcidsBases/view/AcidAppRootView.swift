//
// Reactions App
//

import SwiftUI
import ReactionsCore

public struct AcidAppRootView: View {

    public init(
        model: RootNavigationViewModel<AcidAppNavInjector>,
        unitSelectionIsShowing: Binding<Bool>
    ) {
        self.model = model
        self._unitSelectionIsShowing = unitSelectionIsShowing
    }

    @ObservedObject var model: RootNavigationViewModel<AcidAppNavInjector>
    @Binding var unitSelectionIsShowing: Bool

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public var body: some View {
        ZStack {
            mainBody
                .modifier(BlurredSceneModifier(isBlurred: model.showOnboarding))

            if model.showOnboarding && model.onboardingModel != nil {
                OnboardingView(model: model.onboardingModel!)
            }
        }
    }

    private var mainBody: some View {
        GeometryReader { geo in
            makeView(
                settings: AcidBasesScreenLayout(
                    geometry: geo,
                    verticalSizeClass: verticalSizeClass,
                    horizontalSizeClass: horizontalSizeClass
                )
            )
        }
        .ignoresKeyboardSafeArea()
    }

    private func makeView(settings: AcidBasesScreenLayout) -> some View {
        GeneralRootNavigationView(
            model: model,
            navigationRows: AcidAppNavigationRows.rows,
            menuIconSize: settings.menuSize,
            menuTopPadding: settings.menuTopPadding,
            menuHPadding: settings.menuHPadding,
            unitSelectionIsShowing: $unitSelectionIsShowing
        )
    }
}

private struct BlurredSceneModifier: ViewModifier {
    let isBlurred: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isBlurred {
            content
                .brightness(0.1)
                .overlay(Color.white.opacity(0.6))
                .blur(radius: 6)
                .disabled(true)
        } else {
            content
        }
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
            model: AcidBasesNavigationModel.model(injector: InMemoryAcidAppInjector()),
            unitSelectionIsShowing: .constant(false)
        )
        .previewLayout(.iPhoneSELandscape)
    }
}
