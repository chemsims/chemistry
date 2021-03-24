//
// Reactions App
//

import SwiftUI

public class RootNavigationViewModel2<Injector: NavigationInjector>: ObservableObject {

    @Published public var view: AnyView
    @Published public var showMenu = false

    private(set) public var currentScreen: Screen
    private(set) public var navigationDirection = NavigationDirection.forward

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
            if showMenu {
                showMenu = false
            }
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
        injector.behaviour.getProvider(
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
    public enum NavigationDirection {
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

    func getProvider(
        for screen: Screen,
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) -> ScreenProvider
}

public class AnyNavigationBehavior<Screen>: NavigationBehaviour {

    public init<Behaviour: NavigationBehaviour>(_ behaviour: Behaviour) where Behaviour.Screen == Screen {
        self._deferCanSelect = behaviour.deferCanSelect
        self._shouldRestoreState = behaviour.shouldRestoreStateWhenJumpingTo
        self._showReviewPrompt = behaviour.showReviewPromptOn
        self._highlightNavIcon = behaviour.highlightedNavIcon
        self._getProvider = behaviour.getProvider
    }

    private let _deferCanSelect: (Screen) -> Screen?
    private let _shouldRestoreState: (Screen) -> Bool
    private let _showReviewPrompt: (Screen) -> Bool
    private let _highlightNavIcon: (Screen) -> Screen?
    private let _getProvider: (Screen, @escaping () -> Void, @escaping () -> Void) -> ScreenProvider

    public func deferCanSelect(of screen: Screen) -> Screen? {
        _deferCanSelect(screen)
    }

    public func shouldRestoreStateWhenJumpingTo(screen: Screen) -> Bool {
        _shouldRestoreState(screen)
    }

    public func showReviewPromptOn(screen: Screen) -> Bool {
        _showReviewPrompt(screen)
    }

    public func highlightedNavIcon(for screen: Screen) -> Screen? {
        _highlightNavIcon(screen)
    }

    public func getProvider(
        for screen: Screen,
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) -> ScreenProvider {
        _getProvider(screen, nextScreen, prevScreen)
    }
}

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
