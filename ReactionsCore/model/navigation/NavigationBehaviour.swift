//
// Reactions App
//

import Foundation

public protocol NavigationBehaviour {

    associatedtype Screen

    /// Returns an alternative screen to check if it can be selected
    ///
    /// If the alternative screen can be selected, then the input screen can also be selected
    func deferCanSelect(of screen: Screen) -> DeferCanSelect<Screen>?

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

public enum DeferCanSelect<Screen> {
    case canSelect(other: Screen)
    case hasCompleted(other: Screen)
}

public class AnyNavigationBehavior<Screen>: NavigationBehaviour {

    public init<Behaviour: NavigationBehaviour>(_ behaviour: Behaviour) where Behaviour.Screen == Screen {
        self._deferCanSelect = behaviour.deferCanSelect
        self._shouldRestoreState = behaviour.shouldRestoreStateWhenJumpingTo
        self._showReviewPrompt = behaviour.showReviewPromptOn
        self._highlightNavIcon = behaviour.highlightedNavIcon
        self._getProvider = behaviour.getProvider
    }

    private let _deferCanSelect: (Screen) -> DeferCanSelect<Screen>?
    private let _shouldRestoreState: (Screen) -> Bool
    private let _showReviewPrompt: (Screen) -> Bool
    private let _highlightNavIcon: (Screen) -> Screen?
    private let _getProvider: (Screen, @escaping () -> Void, @escaping () -> Void) -> ScreenProvider

    public func deferCanSelect(of screen: Screen) -> DeferCanSelect<Screen>? {
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
