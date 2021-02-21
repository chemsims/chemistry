//
// Reactions App
//
  

import Foundation

protocol LastOpenedScreenPersistence {
    func get() -> AppScreen?
    func set(_ screen: AppScreen)
}

class UserDefaultsLastOpenedScreenPersistence: LastOpenedScreenPersistence {

    private let defaults = UserDefaults.standard

    private let key = "lastOpenedScreen"

    func get() -> AppScreen? {
        defaults.string(forKey: key).flatMap {
            AppScreen.init(rawValue: $0)
        }
    }

    func set(_ screen: AppScreen) {
        defaults.set(screen.rawValue, forKey: key)
    }

}
