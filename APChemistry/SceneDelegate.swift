//
// Reactions App
//


import UIKit
import SwiftUI
import ReactionsCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        let mode = APChemApp.isDebug ? "debug" : "release"
        print("Running in \(mode) mode")

        let injector = APChemApp.injector
        let tipOverlayModel = TipOverlayViewModel(
            persistence: injector.tipOverlayPersistence,
            locker: injector.storeManager.locker,
            analytics: injector.analytics
        )
        let contentView = APChemRootView(
            navigation: APChemRootNavigationModel(
                injector: injector,
                tipOverlayModel: tipOverlayModel
            ),
            tipModel: .init(
                storeManager: injector.storeManager,
                analytics: injector.analytics
            ),
            tipOverlayModel: tipOverlayModel,
            sharePromptModel: injector.sharePrompter
        )

        let deferScreenEdgesController = DeferScreenEdgesHostingController(
            rootView: contentView
        )
        DeferScreenEdgesState.shared.didSetEdgesDelegate = deferScreenEdgesController.didSetEdges

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = deferScreenEdgesController
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

struct APChemApp {
    static let injector: APChemInjector = {
        if isDebug {
            return DebugAPChemInjector()
        }
        return ProductionAPChemInjector()
    }()

    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}

