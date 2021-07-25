//
// Reactions App
//


import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = APChemRootView(
            navigation: APChemRootNavigationModel(injector: APChemApp.injector),
            storeManager: APChemApp.injector.storeManager
        )

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
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

