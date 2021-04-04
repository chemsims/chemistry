//
// Reactions App
//

import SwiftUI
import ReactionsCore
import CoreMotion

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let injector = InMemoryEquilibriumInjector()
        let navModel = ReactionsEquilibriumNavigationModel.model(using: injector)
        let contentView = ReactionEquilibriumRootView(model: navModel)

//        let contentView = SolubleBeakerView(
//            waterColor: Styling.beakerLiquid,
//            model: SoluteBeakerShakingViewModel(),
//            settings: SolubleBeakerSettings(
//                beakerWidth: 180,
//                waterHeight: 100
//            )
//        )
//        .frame(height: 350)

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
