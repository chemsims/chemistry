//
// Reactions App
//

import SwiftUI

public class RootNavigationViewModel<Injector: NavigationInjector>: ObservableObject {

    @Published public var view: AnyView
    @Published public var showMenu = false {
        didSet {
            if showMenu {
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            } else {
                showAnalyticsConsent = false
            }
        }
    }
    @Published var showAnalyticsConsent = false

    private(set) public var currentScreen: Screen
    private(set) public var navigationDirection = NavigationDirection.forward

    private var injector: Injector
    private let persistence: Injector.Persistence
    private let behaviour: Injector.Behaviour
    private var models = [Screen: ScreenProvider]()

    public typealias Screen = Injector.Screen

    private var hasOpenedFirstScreen = false

    public init(
        injector: Injector,
        generalAnalytics: GeneralAppAnalytics
    ) {
        let lastOpenedScreen = injector.persistence.lastOpened()
        let firstScreen = lastOpenedScreen ?? injector.linearScreens.first!

        self.currentScreen = firstScreen
        self.injector = injector
        self.persistence = injector.persistence
        self.behaviour = injector.behaviour
        self.generalAnalytics = generalAnalytics

        self.view = AnyView(EmptyView())
        self.analyticsConsent = AnalyticsConsentViewModel(service: injector.analytics)

        goTo(screen: firstScreen, with: getProvider(for: firstScreen))
    }

    public private(set) var onboardingModel: OnboardingViewModel?

    let analyticsConsent: AnalyticsConsentViewModel<Injector.Analytics>

    private let generalAnalytics: GeneralAppAnalytics

    public weak var delegate: RootNavigationViewModelDelegate? = nil

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

    public func didShowShareSheetFromMenu() {
        generalAnalytics.tappedShareFromMenu()
    }
}

extension RootNavigationViewModel {
    private func next(from screen: Injector.Screen) {
        guard screen == currentScreen else {
            return
        }
        if let nextScreen = injector.linearScreens.element(after: currentScreen) {
            persistence.setCompleted(screen: currentScreen)
            goToFresh(screen: nextScreen)
        }
    }

    private func prev(from screen: Injector.Screen) {
        guard screen == currentScreen else {
            return
        }
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
            nextScreen: { [weak self] in self?.next(from: screen) },
            prevScreen: { [weak self] in self?.prev(from: screen) }
        )
    }

    private func goTo(screen: Screen, with provider: ScreenProvider) {
        delegate?.screenWillChange()
        models[screen] = provider
        navigationDirection = screenIsAfterCurrent(nextScreen: screen) ? .forward : .back
        currentScreen = screen
        withAnimation(navigationAnimation) {
            view = provider.screen
        }

        // Only show review prompt or open menu if the app is not the first screen shown when app opens
        if hasOpenedFirstScreen {
            let reviewPrompter = ReviewPrompter(
                persistence: injector.reviewPersistence,
                appLaunches: injector.appLaunchPersistence,
                analytics: generalAnalytics
            )
            let doShowReview = reviewPrompter.shouldRequestReview(
                navBehaviourRequestsReview: behaviour.showReviewPromptOn(screen: screen)
            )

            // show either review prompt or share prompt, never both
            if doShowReview {
                reviewPrompter.requestReview()
            } else if injector.sharePrompter.shouldShowPrompt() {
                injector.sharePrompter.showPrompt()
            }

            if behaviour.showMenuOn(screen: screen) {
                showMenu = true
            }
        }
        injector.analytics.opened(screen: screen)
        persistence.setLastOpened(screen)
        hasOpenedFirstScreen = true
    }
}

extension RootNavigationViewModel {
    public func categoryItem(screen: Screen, name: String) -> BranchMenu.CategoryItem {
        .init(
            name: name,
            isSelected: currentScreen == screen,
            canSelect: self.canSelect(screen: screen),
            action: {
                self.jumpTo(screen: screen)
                self.showMenu = false
            }
        )
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
