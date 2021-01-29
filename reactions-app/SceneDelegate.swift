//
//  SceneDelegate.swift
//  reactions-app
//
//  Created by Omar Fahmy on 10/11/2020.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = RootNavigationView(
            model: RootNavigationViewModel(
                injector: ProductionInjector()
            )
        )

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let controller = DeferScreenEdgesHostingController(rootView: contentView)
            DeferScreenEdgesState.shared.didSetEdgesDelegate = controller.didSetEdges
            window.rootViewController = controller
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

