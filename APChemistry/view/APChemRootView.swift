//
// Reactions App
//

import SwiftUI
import ReactionsCore
import Equilibrium
import ReactionRates

struct APChemRootView: View {

    @ObservedObject var navigation: APChemRootNavigationModel
    @ObservedObject var storeManager: StoreManager
    @ObservedObject var notificationModel = NotificationViewModel.shared

    var body: some View {
        ZStack {
            mainView
                .modifier(BlurredSceneModifier(isBlurred: navigation.showOnboarding))

            if navigation.showOnboarding && navigation.onboardingModel != nil {
                OnboardingView(
                    model: navigation.onboardingModel!
                )
            }
        }
        .ignoresKeyboardSafeArea()
    }

    private var mainView: some View {
        GeometryReader { geo in
            navigation.view
                .sheet(isPresented: $navigation.showUnitSelection) {
                    unitSelection(geo)
                        .notification(notificationModel.notification)
                }
        }
        // Only add this on iPhone, since the view is visible behind the sheet on iPad
        // so notification shows up twice. It was not possible to add a single overlay
        // to both the sheet and background view.
        .modifyIf(isIphone) {
            $0.notification(notificationModel.notification)
        }
    }

    private var isIphone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    private func unitSelection(_ geo: GeometryProxy) -> some View {
        UnitSelection(
            navigation: navigation,
            model: storeManager,
            layout: .init(
                geometry: geo,
                verticalSizeClass: nil,
                horizontalSizeClass: nil
            )
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
