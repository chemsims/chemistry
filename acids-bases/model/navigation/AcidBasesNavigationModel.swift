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
        let namePersistence = UserDefaultsNamePersistence()
        return AnyNavigationInjector(
            behaviour: AnyNavigationBehavior(
                AcidAppNavigationBehaviour(namePersistence: namePersistence)
            ),
            persistence: AnyScreenPersistence(InMemoryScreenPersistence()),
            analytics: AnyAppAnalytics(NoOpAppAnalytics()),
            quizPersistence: AnyQuizPersistence(InMemoryQuizPersistence()),
            reviewPersistence: InMemoryReviewPromptPersistence(),
            onboardingPersistence: UserDefaultsOnboardingPersistence(),
            namePersistence: namePersistence,
            allScreens: AcidAppScreen.allCases,
            linearScreens: [.titration]
        )
    }
}

private struct AcidAppNavigationBehaviour: NavigationBehaviour {
    typealias Screen = AcidAppScreen

    let namePersistence: NamePersistence

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
        screen.getProvider(nextScreen: nextScreen, prevScreen: prevScreen, namePersistence: namePersistence)
    }
}

fileprivate extension AcidAppScreen {
    func getProvider(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void,
        namePersistence: NamePersistence
    ) -> ScreenProvider {
        switch self {
        case .introduction:
            return IntroductionScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen,
                namePersistence: namePersistence
            )
        case .buffer:
            return BufferScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen,
                namePersistence: namePersistence
            )
        case .titration:
            return TitrationScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen,
                namePersistence: namePersistence
            )
        }
    }
}

private class IntroductionScreenProvider: ScreenProvider {
    init(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void,
        namePersistence: NamePersistence
    ) {
        let model = IntroScreenViewModel(namePersistence: namePersistence)
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
        prevScreen: @escaping () -> Void,
        namePersistence: NamePersistence
    ) {
        let model = BufferScreenViewModel(namePersistence: namePersistence)
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
        prevScreen: @escaping () -> Void,
        namePersistence: NamePersistence
    ) {
        self.model = TitrationViewModel(namePersistence: namePersistence)
    }

    private let model: TitrationViewModel

    var screen: AnyView {
        AnyView(TitrationScreen(model: model))
    }
}
