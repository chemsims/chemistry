//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct ReactionsEquilibriumNavigationModel {

    typealias Injector = AnyNavigationInjector<EquilibriumAppScreen, EquilibriumQuestionSet>

    static func model(using injector: EquilibriumInjector) -> RootNavigationViewModel<Injector> {
        RootNavigationViewModel(injector: makeInjector(using: injector))
    }

    private static func makeInjector(using injector: EquilibriumInjector) -> Injector {
        AnyNavigationInjector(
            behaviour: AnyNavigationBehavior(
                EquilibriumNavigationBehaviour(injector: injector)
            ),
            persistence: injector.screenPersistence,
            analytics: injector.analytics,
            quizPersistence: injector.quizPersistence,
            allScreens: EquilibriumAppScreen.allCases,
            linearScreens: linearScreens
        )
    }

    private static let linearScreens: [EquilibriumAppScreen] = [
        .aqueousReaction,
        .aqueousQuiz,
        .gaseousReaction,
        .gaseousQuiz,
        .solubility,
        .solubilityQuiz
    ]
}

private struct EquilibriumNavigationBehaviour: NavigationBehaviour {
    typealias Screen = EquilibriumAppScreen

    let injector: EquilibriumInjector

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
        screen.getProvider(
            injector: injector,
            nextScreen: nextScreen,
            prevScreen: prevScreen
        )
    }
}

fileprivate extension EquilibriumAppScreen {
    func getProvider(
        injector: EquilibriumInjector,
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) -> ScreenProvider {

        func quiz(_ questions: QuizQuestionsList<EquilibriumQuestionSet>) -> ScreenProvider {
            QuizScreenProvider(
                questions: questions,
                persistence: injector.quizPersistence,
                analytics: injector.analytics,
                next: nextScreen,
                prev: prevScreen
            )
        }

        switch self {
        case .aqueousReaction:
            return AqueousReactionScreenProvider(nextScreen: nextScreen, prevScreen: prevScreen)
        case .gaseousReaction:
            return GaseousReactionScreenProvider(nextScreen: nextScreen, prevScreen: prevScreen)
        case .solubility:
            return SolubilityScreenProvider(nextScreen: nextScreen, prevScreen: prevScreen)
        case .aqueousQuiz:
            return quiz(.aqueous)
        case .gaseousQuiz:
            return quiz(.gaseous)
        case .solubilityQuiz:
            return quiz(.solubility)
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

private class QuizScreenProvider: ScreenProvider {

    init(
        questions: QuizQuestionsList<EquilibriumQuestionSet>,
        persistence: AnyQuizPersistence<EquilibriumQuestionSet>,
        analytics: AnyAppAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet>,
        next: @escaping () -> Void,
        prev: @escaping () -> Void
    ) {
        self.model = QuizViewModel(questions: questions, persistence: persistence, analytics: analytics)
        self.model.nextScreen = next
        self.model.prevScreen = prev
    }

    let model: QuizViewModel<AnyQuizPersistence<EquilibriumQuestionSet>, AnyAppAnalytics<EquilibriumAppScreen, EquilibriumQuestionSet>>

    var screen: AnyView {
        AnyView(QuizScreen(model: model))
    }

}
