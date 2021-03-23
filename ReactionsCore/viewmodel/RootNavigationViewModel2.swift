//
// Reactions App
//

import SwiftUI

public class RootNavigationViewModel2<Injector: NavigationInjector>: ObservableObject {

    @Published var view: AnyView
    @Published var showMenu = false

    private(set) var currentScreen: Screen
    private(set) var navigationDirection = NavigationDirection.forward

    private let injector: Injector
    private let persistence: Injector.Persistence
    private let behaviour: Injector.Behaviour
    private var models = [Screen: ScreenProvider]()

    public typealias Screen = Injector.Screen

    public init(
        injector: Injector
    ) {
        let lastOpenedScreen = injector.persistence.lastOpened()
        let firstScreen = lastOpenedScreen ?? injector.linearScreens.first!

        self.currentScreen = firstScreen
        self.injector = injector
        self.persistence = injector.persistence
        self.behaviour = injector.behaviour

        self.view = AnyView(EmptyView())
        goTo(screen: firstScreen, with: getProvider(for: firstScreen))
    }

    public var highlightedIcon: Screen? {
        behaviour.highlightedNavIcon(for: currentScreen)
    }

    public func canSelect(screen: Screen) -> Bool {
        if let deferredScreen = behaviour.deferCanSelect(of: screen) {
            return canSelect(screen: deferredScreen)
        }
        if let previousScreen = injector.linearScreens.element(before: screen) {
            return persistence.hasCompleted(screen: previousScreen)
        }
        return true
    }

    public func jumpTo(screen: Screen) {
        if behaviour.shouldRestoreStateWhenJumpingTo(screen: screen) {
            goToExisting(screen: screen)
        } else {
            goToFresh(screen: screen)
        }
    }
}

extension RootNavigationViewModel2 {
    private func next() {
        if let nextScreen = injector.linearScreens.element(after: currentScreen) {
            persistence.setCompleted(screen: currentScreen)
            goToFresh(screen: nextScreen)
        }
    }

    private func prev() {
        if let prevScreen = injector.linearScreens.element(before: currentScreen) {
            goToExisting(screen: prevScreen)
        }
    }
}

extension RootNavigationViewModel2 {

    private func goToFresh(screen: Screen) {
        guard screen != currentScreen else {
            return
        }
        goTo(screen: screen, with: getProvider(for: screen))
    }

    private func goToExisting(screen: Screen) {
        guard screen != currentScreen else {
            return
        }
        let provider = models[screen] ?? getProvider(for: screen)
        goTo(screen: screen, with: provider)
    }

    private func getProvider(for screen: Screen) -> ScreenProvider {
        injector.getProvider(
            for: screen,
            nextScreen: next,
            prevScreen: prev
        )
    }

    private func goTo(screen: Screen, with provider: ScreenProvider) {
        models[screen] = provider
        navigationDirection = screenIsAfterCurrent(nextScreen: screen) ? .forward : .back
        currentScreen = screen
        withAnimation(navigationAnimation) {
            view = provider.screen
        }
        if behaviour.showReviewPromptOn(screen: screen) {
            showMenu = true
        }
        injector.analytics.opened(screen: screen)
        persistence.setLastOpened(screen)
    }
}

extension RootNavigationViewModel2 {
    private var reduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    private var navigationAnimation: Animation? {
        reduceMotion ? nil : Animation.easeOut(duration: 0.35)
    }
}

extension RootNavigationViewModel2 {
    private func screenIsAfterCurrent(nextScreen: Screen) -> Bool {
        if let indexOfCurrent = index(of: currentScreen),
           let indexOfNew = index(of: nextScreen) {
            return indexOfNew > indexOfCurrent
        }
        return false
    }

    private func index(of screen: Screen) -> Int? {
        injector.allScreens.firstIndex(of: screen)
    }
}

extension RootNavigationViewModel2 {
    enum NavigationDirection {
        case forward, back
    }
}

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

    func getProvider(
        for screen: Screen,
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) -> ScreenProvider
}

public protocol NavigationBehaviour {

    associatedtype Screen



    /// Returns an alternative screen to check if it can be selected
    ///
    /// If the alternative screen can be selected, then the input screen can also be selected
    func deferCanSelect(of screen: Screen) -> Screen?

    /// Returns whether the previous screen state should be restored when navigating to this screen from the menu
    func shouldRestoreStateWhenJumpingTo(screen: Screen) -> Bool
    
    func showReviewPromptOn(screen: Screen) -> Bool

    func highlightedNavIcon(for screen: Screen) -> Screen?
}

public protocol ScreenPersistence {
    associatedtype Screen

    func setCompleted(screen: Screen)
    func hasCompleted(screen: Screen) -> Bool

    func lastOpened() -> Screen?
    func setLastOpened(_ screen: Screen)
}

public protocol AppAnalytics {
    associatedtype Screen

    func opened(screen: Screen)
}
