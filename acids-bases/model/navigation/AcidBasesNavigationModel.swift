//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidBasesNavigationModel {
    private init() { }

    typealias Injector = AnyNavigationInjector<AcidAppScreen, AcidAppQuestionSet>

    static func model() -> RootNavigationViewModel<Injector> {
        RootNavigationViewModel(injector: makeInjector())
    }

    private static func makeInjector() -> Injector {
        AnyNavigationInjector(
            behaviour: AnyNavigationBehavior(AcidAppNavigationBehaviour()),
            persistence: AnyScreenPersistence(InMemoryScreenPersistence()),
            analytics: AnyAppAnalytics(NoOpAppAnalytics()),
            quizPersistence: AnyQuizPersistence(InMemoryQuizPersistence()),
            reviewPersistence: InMemoryReviewPromptPersistence(),
            onboardingPersistence: InMemoryOnboardingPersistence(),
            namePersistence: InMemoryNamePersistence(),
            allScreens: AcidAppScreen.allCases,
            linearScreens: AcidAppScreen.allCases
        )
    }
}

private struct AcidAppNavigationBehaviour: NavigationBehaviour {
    typealias Screen = AcidAppScreen

    func deferCanSelect(of screen: AcidAppScreen) -> DeferCanSelect<AcidAppScreen>? {
       nil
    }

    func shouldRestoreStateWhenJumpingTo(screen: AcidAppScreen) -> Bool {
        false
    }

    func showReviewPromptOn(screen: AcidAppScreen) -> Bool {
        false
    }

    func showMenuOn(screen: AcidAppScreen) -> Bool {
        false
    }

    func highlightedNavIcon(for screen: AcidAppScreen) -> AcidAppScreen? {
        nil
    }

    func getProvider(
        for screen: AcidAppScreen,
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) -> ScreenProvider {
        screen.getProvider(nextScreen: nextScreen, prevScreen: prevScreen)
    }
}

fileprivate extension AcidAppScreen {
    func getProvider(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) -> ScreenProvider {
        switch self {
        case .introduction:
            return IntroductionScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen
            )
        case .buffer:
            return BufferScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen
            )
        case .titration:
            return TitrationScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen
            )
        }
    }
}

private class IntroductionScreenProvider: ScreenProvider {
    init(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) {
        let model = IntroScreenViewModel()
        model.navigation?.nextScreen = nextScreen
        model.navigation?.prevScreen = prevScreen
        self.model = model
    }

    private let model: IntroScreenViewModel

    var screen: AnyView {
        AnyView(IntroScreen(model: model))
    }
}

private class BufferScreenProvider: ScreenProvider {
    init(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) {
        let model = BufferScreenViewModel()
        model.navigation?.nextScreen = nextScreen
        model.navigation?.prevScreen = prevScreen
        self.model = model
    }

    private let model: BufferScreenViewModel

    var screen: AnyView {
        AnyView(BufferScreen(model: model))
    }
}

private class TitrationScreenProvider: ScreenProvider {
    init(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) {
        self.model = TitrationViewModel()
    }

    private let model: TitrationViewModel

    var screen: AnyView {
        AnyView(TitrationScreen(model: model))
    }
}
