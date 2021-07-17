//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct AcidBasesNavigationModel {
    private init() { }

    typealias Injector = AnyNavigationInjector<AcidAppScreen, AcidAppQuestionSet>

    static func model(injector: AcidAppInjector) -> RootNavigationViewModel<Injector> {
        RootNavigationViewModel(
            injector: makeInjector(using: injector)
        )
    }

    private static func makeInjector(using appInjector: AcidAppInjector) -> Injector {
        AnyNavigationInjector(
            behaviour: AnyNavigationBehavior(
                AcidAppNavigationBehaviour(injector: appInjector)
            ),
            persistence: appInjector.screenPersistence,
            analytics: appInjector.analytics,
            quizPersistence: appInjector.quizPersistence,
            reviewPersistence: appInjector.reviewPersistence,
            onboardingPersistence: appInjector.onboardingPersistence,
            namePersistence: appInjector.namePersistence,
            allScreens: AcidAppScreen.allCases,
            linearScreens: AcidAppScreen.allCases
        )
    }
}

private struct AcidAppNavigationBehaviour: NavigationBehaviour {
    typealias Screen = AcidAppScreen

    let injector: AcidAppInjector

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
        screen.getProvider(
            nextScreen: nextScreen,
            prevScreen: prevScreen,
            injector: injector
        )
    }
}

fileprivate extension AcidAppScreen {
    func getProvider(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void,
        injector: AcidAppInjector
    ) -> ScreenProvider {

        func quiz(_ questions: QuizQuestionsList<AcidAppQuestionSet>) -> ScreenProvider {
            QuizScreenProvider(
                questions: questions,
                persistence: injector.quizPersistence,
                analytics: injector.analytics,
                next: nextScreen,
                prev: prevScreen
            )
        }

        switch self {
        case .introduction:
            return IntroductionScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen,
                substancePersistence: injector.substancePersistence,
                namePersistence: injector.namePersistence
            )
        case .buffer:
            return BufferScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen,
                substancePersistence: injector.substancePersistence,
                namePersistence: injector.namePersistence
            )
        case .titration:
            return TitrationScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen,
                namePersistence: injector.namePersistence
            )

        case .introductionQuiz:
            return quiz(.introduction)

        case .bufferQuiz:
            return quiz(.buffer)

        case .titrationQuiz:
            return quiz(.titration)
        }
    }
}

private class IntroductionScreenProvider: ScreenProvider {
    init(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void,
        substancePersistence: AcidOrBasePersistence,
        namePersistence: NamePersistence
    ) {
        let model = IntroScreenViewModel(
            substancePersistence: substancePersistence,
            namePersistence: namePersistence
        )
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
        substancePersistence: AcidOrBasePersistence,
        namePersistence: NamePersistence
    ) {
        let model = BufferScreenViewModel(
            substancePersistence: substancePersistence,
            namePersistence: namePersistence
        )
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

private class QuizScreenProvider: ScreenProvider {
    init(
        questions: QuizQuestionsList<AcidAppQuestionSet>,
        persistence: AnyQuizPersistence<AcidAppQuestionSet>,
        analytics: AnyAppAnalytics<AcidAppScreen, AcidAppQuestionSet>,
        next: @escaping () -> Void,
        prev: @escaping () -> Void
    ) {
        self.model = QuizViewModel(
            questions: questions,
            persistence: persistence,
            analytics: analytics
        )
        self.model.nextScreen = next
        self.model.prevScreen = prev
    }

    let model: QuizViewModel<
        AnyQuizPersistence<AcidAppQuestionSet>,
        AnyAppAnalytics<AcidAppScreen, AcidAppQuestionSet>
    >

    var screen: AnyView {
        AnyView(QuizScreen(model: model))
    }

}
