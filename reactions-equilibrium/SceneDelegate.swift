//
// Reactions App
//

import SwiftUI
import ReactionsCore
import CoreMotion

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = RootNavigationView(model: RootNavigationModel())
        let controller = DeferScreenEdgesHostingController(rootView: contentView)
        DeferScreenEdgesState.shared.didSetEdgesDelegate = controller.didSetEdges

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = controller
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
