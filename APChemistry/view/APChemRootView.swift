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
    @ObservedObject var sharePromptModel: SharePrompter
    @ObservedObject var notificationModel = NotificationViewModel.shared

    private let shareSettings = ShareSettings()

    var body: some View {
        GeometryReader { geo in
            navigation.view
                .sheet(item: $navigation.activeSheet) {
                    sheet($0, geo: geo)
                }
                .blur(radius: blurContent ? 1 : 0)
                .overlay(tippingOverlay(layout: .init(geometry: geo)))
        }
        .notification(showNotificationOnMainContent ? notificationModel.notification : nil)
    }

    // on iPad, we must not show the notification on both the main content and sheet at the same
    // time since the notification overlay on the main content will be visible behind the sheet.
    // So we only show it on main content when one of the app sheets is not visible. The share
    // sheet is a system sheet, so it seems better to leave the notification behind it.
    private var showNotificationOnMainContent: Bool {
        if isIphone {
            return true
        }
        return navigation.activeSheet != .about && navigation.activeSheet != .unitSelection
    }

    @ViewBuilder
    private func sheet(
        _ activeSheet: APChemRootNavigationModel.ActiveSheet,
        geo: GeometryProxy
    ) -> some View {
        switch activeSheet {
        case .unitSelection:
            unitSelection(geo)
                .notification(notificationModel.notification)
        case .about:
            AboutScreen(model: tipModel, navigation: navigation)
                .notification(notificationModel.notification)

        case .share:
            ShareSheetView(
                activityItems: [shareSettings.message],
                onCompletion: { navigation.activeSheet = nil }
            )
            .edgesIgnoringSafeArea(.all)
        }
    }

    private var blurContent: Bool {
        tipOverlayModel.showModal || sharePromptModel.showingPrompt
    }

    @ViewBuilder
    private func tippingOverlay(layout: SupportStudentsModalSettings) -> some View {
        if blurContent {
            ZStack {
                Color.black
                    .opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        sharePromptModel.dismiss()
                    }

                if tipOverlayModel.showModal {
                    SupportStudentsModal(
                        model: tipModel,
                        tipOverlayModel: tipOverlayModel
                    )
                } else if sharePromptModel.showingPrompt {
                    SharePromptModal(
                        layout: layout,
                        showShareSheet: {
                            navigation.activeSheet = .share
                            sharePromptModel.dismiss()
                            sharePromptModel.clickedShare()
                        },
                        dismissPrompt: sharePromptModel.dismiss
                    )
                }
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

