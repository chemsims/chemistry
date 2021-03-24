//
// Reactions App
//

import Foundation

public protocol AppAnalytics {
    associatedtype Screen

    func opened(screen: Screen)
}

public class AnyAppAnalytics<Screen>: AppAnalytics {

    public init<Analytics: AppAnalytics>(_ analytics: Analytics) where Analytics.Screen == Screen {
        self._opened = analytics.opened
    }

    private let _opened: (Screen) -> Void

    public func opened(screen: Screen) {
        _opened(screen)
    }
}
