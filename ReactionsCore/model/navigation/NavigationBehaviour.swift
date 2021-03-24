//
// Reactions App
//

import Foundation

public protocol NavigationBehaviour {

    associatedtype Screen

    /// Returns an alternative screen to check if the given screen can be opened
    func deferCanSelect(of screen: Screen) -> DeferCanSelect<Screen>?

    /// Returns whether the previous screen state should be restored when navigating to this screen from the menu
    func shouldRestoreStateWhenJumpingTo(screen: Screen) -> Bool

    /// Returns whether the review prompt should be triggered when opening this screen.
    ///
    /// - Note:The review prompt is triggered after some delay, not immediately, and subject to
    /// the conditions in the review prompting logic
    func showReviewPromptOn(screen: Screen) -> Bool

    /// Returns the screen which should have it's navigation icon highlighted in the main menu
    ///
    /// - Note: The is different to a regular focused screen, and is designed to draw attention to a different
    /// screen altogether in the main menu, using a different color. For example, the last screen on the app may
    /// tell the user to visit a different screen next, in which case this screen could be highlighted in the menu
    func highlightedNavIcon(for screen: Screen) -> Screen?

    /// Returns a screen provider for this screen
    ///
    /// Screen providers should maintain their underlying state, so that the same screen can be restored again later
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
