//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ReactionsEquilibriumNavigationModel {

    static func model(using injector: EquilibriumInjector) -> RootNavigationViewModel<AnyNavigationInjector<EquilibriumAppScreen>> {
        RootNavigationViewModel(injector: makeInjector(using: injector))
    }

    private static func makeInjector(using injector: EquilibriumInjector) -> AnyNavigationInjector<EquilibriumAppScreen> {
        AnyNavigationInjector(
            behaviour: AnyNavigationBehavior(EquilibriumNavigationBehaviour()),
            persistence: injector.persistence,
            analytics: injector.screenAnalytics,
            allScreens: EquilibriumAppScreen.allCases,
            linearScreens: EquilibriumAppScreen.allCases
        )
    }
}

private struct EquilibriumNavigationBehaviour: NavigationBehaviour {
    typealias Screen = EquilibriumAppScreen

    func deferCanSelect(of screen: EquilibriumAppScreen) -> DeferCanSelect<EquilibriumAppScreen>? {
        nil
    }

    func shouldRestoreStateWhenJumpingTo(screen: EquilibriumAppScreen) -> Bool {
        false
    }

    func showReviewPromptOn(screen: EquilibriumAppScreen) -> Bool {
        false
    }

    func highlightedNavIcon(for screen: EquilibriumAppScreen) -> EquilibriumAppScreen? {
        nil
    }

    func getProvider(for screen: EquilibriumAppScreen, nextScreen: @escaping () -> Void, prevScreen: @escaping () -> Void) -> ScreenProvider {
        screen.getProvider(nextScreen: nextScreen, prevScreen: prevScreen)
    }
}

fileprivate extension EquilibriumAppScreen {
    func getProvider(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) -> ScreenProvider {
        switch self {
        case .aqueousReaction:
            return AqueousReactionScreenProvider(nextScreen: nextScreen, prevScreen: prevScreen)
        case .gaseousReaction:
            return GaseousReactionScreenProvider(nextScreen: nextScreen, prevScreen: prevScreen)
        case .solubility:
            return SolubilityScreenProvider(nextScreen: nextScreen, prevScreen: prevScreen)
        }
    }
}

private class AqueousReactionScreenProvider: ScreenProvider {
    init(nextScreen: @escaping () -> Void, prevScreen: @escaping () -> Void) {
        let model = AqueousReactionViewModel()
        model.navigation?.nextScreen = nextScreen
        model.navigation?.prevScreen = prevScreen
        self.model = model
    }

    private let model: AqueousReactionViewModel

    var screen: AnyView {
        AnyView(AqueousReactionScreen(model: model))
    }
}

private class GaseousReactionScreenProvider: ScreenProvider {
    init(nextScreen: @escaping () -> Void, prevScreen: @escaping () -> Void) {
        let model = GaseousReactionViewModel()
        model.navigation?.nextScreen = nextScreen
        model.navigation?.prevScreen = prevScreen
        self.model = model
    }

    private let model: GaseousReactionViewModel

    var screen: AnyView {
        AnyView(GaseousReactionScreen(model: model))
    }
}

private class SolubilityScreenProvider: ScreenProvider {

    init(nextScreen: @escaping () -> Void, prevScreen: @escaping () -> Void) {
        let model = SolubilityViewModel()
        model.navigation?.nextScreen = nextScreen
        model.navigation?.prevScreen = prevScreen
        self.model = model
    }

    let model: SolubilityViewModel

    var screen: AnyView {
        AnyView(SolubilityScreen(model: model))
    }
}

protocol EquilibriumInjector {
    var persistence: AnyScreenPersistence<EquilibriumAppScreen> { get }
    var screenAnalytics: AnyAppAnalytics<EquilibriumAppScreen> { get }
}

class InMemoryEquilibriumInjector: EquilibriumInjector {
    let persistence = AnyScreenPersistence(InMemoryScreenPersistence<EquilibriumAppScreen>())
    let screenAnalytics = AnyAppAnalytics(NoOpAppAnalytics<EquilibriumAppScreen>())
}
