//
// Reactions App
//


import UIKit
import SwiftUI
import ReactionsCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        let model = AcidBasesNavigationModel.model(injector: getInjector())
        let rootView = AcidAppRootView(model: model)
        let contentView = rootView

        let controller = DeferScreenEdgesHostingController(rootView: contentView)
        DeferScreenEdgesState.shared.didSetEdgesDelegate = controller.didSetEdges

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = controller
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    private func getInjector() -> AcidAppInjector {
        InMemoryAcidAppInjector()
    }
}

