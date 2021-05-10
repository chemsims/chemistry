//
// Reactions App
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        EquilibriumQuizQuestions.load()
        print("Running in config: \(EquilibriumApp.isDebug ? "debug" : "release")")
        if !EquilibriumApp.isDebug {
            FirebaseApp.configure()
        }
        return true
    }
}

struct EquilibriumApp {
    private init() { }

    static var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}
