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
                    switch $0 {
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
                .blur(radius: blurContent ? 1 : 0)
                .overlay(tippingOverlay(layout: .init(geometry: geo)))
        }
        // Only add this on iPhone, since the view is visible behind the sheet on iPad
        // so notification shows up twice
        .modifyIf(isIphone) {
            $0.notification(notificationModel.notification)
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

