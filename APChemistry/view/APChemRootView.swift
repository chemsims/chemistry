//
// Reactions App
//

import SwiftUI
import ReactionsCore
import Equilibrium
import ReactionRates

struct APChemRootView: View {

    @ObservedObject var navigation: APChemRootNavigationModel
    @ObservedObject var tipModel: TippingViewModel
    @ObservedObject var tipOverlayModel: TipOverlayViewModel
    @ObservedObject var notificationModel = NotificationViewModel.shared

    var body: some View {
        GeometryReader { geo in
            navigation.view
                .sheet(item: $navigation.activeSheet) {
                    switch $0 {
                    case .unitSelection:
                        unitSelection(geo)
                            .notification(notificationModel.notification)
                    case .about:
                        AboutScreen(model: tipModel, navigation: navigation)
                            .notification(notificationModel.notification)
                    }
                }
//                .sheet(isPresented: $navigation.showUnitSelection) {
//                    unitSelection(geo)
//                        .notification(notificationModel.notification)
//                }
                .blur(radius: tipOverlayModel.showModal ? 1 : 0)
                .overlay(tippingOverlay)
        }
        // Only add this on iPhone, since the view is visible behind the sheet on iPad
        // so notification shows up twice
        .modifyIf(isIphone) {
            $0.notification(notificationModel.notification)
        }
    }

    @ViewBuilder
    private var tippingOverlay: some View {
        if tipOverlayModel.showModal {
            ZStack {
                Color.black
                    .opacity(0.1)
                    .edgesIgnoringSafeArea(.all)

                SupportStudentsModal(
                    model: tipModel,
                    tipOverlayModel: tipOverlayModel
                )
            }
        }
    }

    private var isIphone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    private func unitSelection(_ geo: GeometryProxy) -> some View {
        UnitSelection(
            navigation: navigation,
            layout: .init(
                geometry: geo,
                verticalSizeClass: nil,
                horizontalSizeClass: nil
            )
        )
    }
}

