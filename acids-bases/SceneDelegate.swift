//
// Reactions App
//


import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        let contentView = GeometryReader { geo in
            IntroScreen(
                layout: AcidBasesScreenLayout(
                    geometry: geo,
                    verticalSizeClass: nil,
                    horizontalSizeClass: nil
                ),
                model: IntroScreenViewModel()
            )
        }

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

