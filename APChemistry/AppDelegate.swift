//
// Reactions App
//

import UIKit
import Firebase
import Equilibrium

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if !APChemApp.isDebug {
            FirebaseApp.configure()
        }

        EquilibriumQuizQuestions.load()

        APChemApp.injector.storeManager.initialiseStore()
        APChemApp.injector.appLaunchPersistence.recordAppLaunch()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        APChemApp.injector.storeManager.cleanupStore()
    }
}

// MARK: UISceneSession Lifecycle
extension AppDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
