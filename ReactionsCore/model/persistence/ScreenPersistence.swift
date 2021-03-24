//
// Reactions App
//

import Foundation

public protocol ScreenPersistence {
    associatedtype Screen

    func setCompleted(screen: Screen)
    func hasCompleted(screen: Screen) -> Bool

    func lastOpened() -> Screen?
    func setLastOpened(_ screen: Screen)
}

public class UserDefaultsScreenPersistence<Screen: RawRepresentable>: ScreenPersistence where Screen.RawValue == String {

    public init() {
    }

    private let defaults = UserDefaults.standard
    private let lastOpenedKey = "lastOpenedScreen"

    public func setCompleted(screen: Screen) {
        defaults.set(true, forKey: screenKey(screen))
    }

    public func hasCompleted(screen: Screen) -> Bool {
        defaults.bool(forKey: screenKey(screen))
    }

    public func lastOpened() -> Screen? {
        defaults.string(forKey: lastOpenedKey).flatMap {
            Screen.init(rawValue: $0)
        }
    }

    public func setLastOpened(_ screen: Screen) {
        defaults.set(screen.rawValue, forKey: lastOpenedKey)
    }

    private func screenKey(_ screen: Screen) -> String {
        "completed-screen-\(screen.rawValue)"
    }
}

public class InMemoryScreenPersistence<Screen: Hashable>: ScreenPersistence {
    public typealias Screen = Screen

    public init() {
    }

    private var completed = Set<Screen>()
    private var _lastOpened: Screen?

    public func setCompleted(screen: Screen) {
        completed.insert(screen)
    }

    public func hasCompleted(screen: Screen) -> Bool {
        completed.contains(screen)
    }

    public func lastOpened() -> Screen? {
        _lastOpened
    }

    public func setLastOpened(_ screen: Screen) {
        _lastOpened = screen
    }
}
