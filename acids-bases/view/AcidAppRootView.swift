//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidAppRootView: View {

    @ObservedObject var model: RootNavigationViewModel<AcidBasesNavigationModel.Injector>
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
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
            feedbackSettings: .acidBases,
            shareSettings: .acidBases,
            menuIconSize: settings.menuSize,
            menuTopPadding: settings.menuTopPadding,
            menuHPadding: settings.menuHPadding
        )
    }
}

// TODO - move this & fix URL
extension FeedbackSettings {
    static let acidBases = FeedbackSettings(appName: "Acid & Bases")
}
extension ShareSettings {
    static let acidBases = ShareSettings(appStoreUrl: "", appName: "Acid & Bases")
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
