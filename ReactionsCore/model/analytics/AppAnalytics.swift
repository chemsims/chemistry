//
// Reactions App
//

import Foundation

public protocol AppAnalytics {
    associatedtype Screen

    func opened(screen: Screen)

    var enabled: Bool { get }
    func setEnabled(value: Bool)
}

public class AnyAppAnalytics<Screen>: AppAnalytics {

    public init<Analytics: AppAnalytics>(_ analytics: Analytics) where Analytics.Screen == Screen {
        self._opened = analytics.opened
        self._getEnabled = { analytics.enabled }
        self._setEnabled = analytics.setEnabled
    }


    private let _opened: (Screen) -> Void
    private let _getEnabled: () -> Bool
    private let _setEnabled: (Bool) -> Void

    public func opened(screen: Screen) {
        _opened(screen)
    }

    public var enabled: Bool {
        _getEnabled()
    }

    public func setEnabled(value: Bool) {
        _setEnabled(value)
    }
}

public class NoOpAppAnalytics<Screen>: AppAnalytics {
    public init() { }
    
    public func opened(screen: Screen) { }

    private(set) public var enabled: Bool = false

    public func setEnabled(value: Bool) {
        enabled = value
    }
}
