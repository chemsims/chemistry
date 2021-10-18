//
// Reactions App
//

import UIKit
import Firebase
import ReactionsCore
import Equilibrium
import AcidsBases
import ChemicalReactions

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if !APChemApp.isDebug {
            FirebaseApp.configure()
            setAnalytics()
        }

        // TODO - make a general version of these load functions and put them on each injector.
        // Then we can call them on the injector for each unit.
        EquilibriumQuizQuestions.load()
        AcidQuizQuestions.load()
        ChemicalReactionsQuizQuestions.load()

        APChemApp.injector.storeManager.initialiseStore()
        APChemApp.injector.appLaunchPersistence.recordAppLaunch()

        return true
    }

    private func setAnalytics() {
        let enabled = Countries.shouldEnableAnalytics()
        APChemApp.injector.analytics.setEnabled(value: enabled)
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
