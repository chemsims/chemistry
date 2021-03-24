//
// Reactions App
//

import SwiftUI

public class RootNavigationViewModel<Injector: NavigationInjector>: ObservableObject {

    @Published public var view: AnyView
    @Published public var showMenu = true

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
        if let deferOption = behaviour.deferCanSelect(of: screen) {
            switch deferOption {
            case let .canSelect(other):
                return canSelect(screen: other)
            case let .hasCompleted(other):
                return persistence.hasCompleted(screen: other)
            }
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

extension RootNavigationViewModel {
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

extension RootNavigationViewModel {

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

extension RootNavigationViewModel {
    private var reduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    private var navigationAnimation: Animation? {
        reduceMotion ? nil : Animation.easeOut(duration: 0.35)
    }
}

extension RootNavigationViewModel {
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

extension RootNavigationViewModel {
    public enum NavigationDirection {
        case forward, back
    }
}
