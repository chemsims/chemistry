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

public class AnyScreenPersistence<Screen>: ScreenPersistence {
    public init<Persistence: ScreenPersistence>(_ persistence: Persistence) where Persistence.Screen == Screen {
        self._setCompleted = persistence.setCompleted
        self._hasCompleted = persistence.hasCompleted
        self._lastOpened = persistence.lastOpened
        self._setLastOpened = persistence.setLastOpened
    }

    private let _setCompleted: (Screen) -> Void
    private let _hasCompleted: (Screen) -> Bool
    private let _lastOpened: () -> Screen?
    private let _setLastOpened: (Screen) -> Void

    public func setCompleted(screen: Screen) {
        _setCompleted(screen)
    }

    public func hasCompleted(screen: Screen) -> Bool {
        _hasCompleted(screen)
    }

    public func lastOpened() -> Screen? {
        _lastOpened()
    }

    public func setLastOpened(_ screen: Screen) {
        _setLastOpened(screen)
    }
}

public class UserDefaultsScreenPersistence<Screen: RawRepresentable>: ScreenPersistence where Screen.RawValue == String {

    public init(prefix: String) {
        let prefixWithDot = prefix.isEmpty ? "" : "\(prefix)."
        self.prefixWithDot = prefixWithDot
        self.lastOpenedKey = "\(prefixWithDot)lastOpenedScreen"
    }

    private let defaults = UserDefaults.standard
    private let prefixWithDot: String
    private let lastOpenedKey: String

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
        "\(prefixWithDot)completed-screen-\(screen.rawValue)"
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

public class NoOpScreenPersistence<Screen>: ScreenPersistence {
    public init(lastOpened: Screen? = nil) {
        self._lastOpened = lastOpened
    }

    private let _lastOpened: Screen?

    public func setCompleted(screen: Screen) {
    }

    public func hasCompleted(screen: Screen) -> Bool {
        true
    }

    public func lastOpened() -> Screen? {
        _lastOpened
    }

    public func setLastOpened(_ screen: Screen) {
    }
}
