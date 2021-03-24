//
// Reactions App
//

import Foundation

public protocol NavigationInjector {
    associatedtype Screen: Hashable
    associatedtype Behaviour: NavigationBehaviour where Behaviour.Screen == Screen
    associatedtype Persistence: ScreenPersistence where Persistence.Screen == Screen
    associatedtype Analytics: AppAnalytics where Analytics.Screen == Screen

    var behaviour: Behaviour { get }

    var persistence: Persistence { get }

    var analytics: Analytics { get }

    var allScreens: [Screen] { get }

    var linearScreens: [Screen] { get }
}

public class AnyNavigationInjector<Screen: Hashable>: NavigationInjector {
    public init(
        behaviour: AnyNavigationBehavior<Screen>,
        persistence: AnyScreenPersistence<Screen>,
        analytics: AnyAppAnalytics<Screen>,
        allScreens: [Screen],
        linearScreens: [Screen]
    ) {
        self.behaviour = behaviour
        self.persistence = persistence
        self.analytics = analytics
        self.allScreens = allScreens
        self.linearScreens = linearScreens
    }

    public let behaviour: AnyNavigationBehavior<Screen>
    public let persistence: AnyScreenPersistence<Screen>
    public let analytics: AnyAppAnalytics<Screen>
    public let allScreens: [Screen]
    public let linearScreens: [Screen]
}
