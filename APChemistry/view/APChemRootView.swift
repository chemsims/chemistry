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
        GeometryReader { geo in
            navigation.view
                .sheet(isPresented: $navigation.showUnitSelection) {
                    unitSelection(geo)
                        .notification(notificationModel.notification)
                }
        }
        // Only add this on iPhone, since the view is visible behind the sheet on iPad
        // so notification shows up twice
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

