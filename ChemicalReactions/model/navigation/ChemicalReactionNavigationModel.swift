//
// Reactions App
//

import SwiftUI
import ReactionsCore

public typealias ChemicalReactionsAppNavInjector = AnyNavigationInjector<ChemicalReactionsScreen, ChemicalReactionsQuestionSet>

extension RootNavigationViewModel where Injector == ChemicalReactionsAppNavInjector {

    public static func production(
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) -> RootNavigationViewModel<ChemicalReactionsAppNavInjector> {
        model(
            using: ProductionChemicalReactionsInjector(),
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunchPersistence,
            analytics: analytics
        )
    }

    public static func inMemory(
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) -> RootNavigationViewModel<ChemicalReactionsAppNavInjector> {
        model(
            using: InMemoryChemicalReactionsInjector(),
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunchPersistence,
            analytics: analytics
        )
    }

    private static func model(
        using injector: ChemicalReactionsInjector,
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) -> RootNavigationViewModel<ChemicalReactionsAppNavInjector> {
        RootNavigationViewModel(
            injector: makeInjector(
                using: injector,
                sharePrompter: sharePrompter,
                appLaunchPersistence: appLaunchPersistence
            ),
            generalAnalytics: analytics
        )
    }

    private static func makeInjector(
        using appInjector: ChemicalReactionsInjector,
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence
    ) -> ChemicalReactionsAppNavInjector {
        AnyNavigationInjector(
            behaviour: AnyNavigationBehavior(
                ChemicalReactionsAppNavigationBehaviour(injector: appInjector)
            ),
            persistence: appInjector.screenPersistence,
            analytics: appInjector.analytics,
            quizPersistence: appInjector.quizPersistence,
            reviewPersistence: appInjector.reviewPersistence,
            namePersistence: appInjector.namePersistence,
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunchPersistence,
            allScreens: ChemicalReactionsScreen.allCases,
            linearScreens: ChemicalReactionsScreen.allCases
        )
    }
}

private struct ChemicalReactionsAppNavigationBehaviour: NavigationBehaviour {
    typealias Screen = ChemicalReactionsScreen

    let injector: ChemicalReactionsInjector

    func deferCanSelect(of screen: ChemicalReactionsScreen) -> DeferCanSelect<ChemicalReactionsScreen>? {
        return nil
    }

    func shouldRestoreStateWhenJumpingTo(screen: ChemicalReactionsScreen) -> Bool {
        screen.isQuiz
    }

    func showReviewPromptOn(screen: ChemicalReactionsScreen) -> Bool {
        screen == .precipitation
    }

    func showMenuOn(screen: ChemicalReactionsScreen) -> Bool {
        false
    }

    func highlightedNavIcon(for screen: ChemicalReactionsScreen) -> ChemicalReactionsScreen? {
        nil
    }

    func getProvider(
        for screen: ChemicalReactionsScreen,
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) -> ScreenProvider {

        func quiz(_ questions: QuizQuestionsList<ChemicalReactionsQuestionSet>) -> ScreenProvider {
            QuizScreenProvider(
                questions: questions,
                persistence: injector.quizPersistence,
                analytics: injector.analytics,
                next: nextScreen,
                prev: prevScreen
            )
        }

        switch screen {
        case .balancedReactions:
            return BalancedReactionScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen
            )
        case .limitingReagent:
            return LimitingReagentScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen
            )
        case .precipitation:
            return PrecipitationScreenProvider(
                nextScreen: nextScreen,
                prevScreen: prevScreen
            )

        case .balancedReactionsQuiz:
            return quiz(.balancedReactions)

        case .limitingReagentQuiz:
            return quiz(.limitingReagent)

        case .precipitationQuiz:
            return quiz(.precipitation)
        }
    }
}

private class BalancedReactionScreenProvider: ScreenProvider {
    init(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) {
        let model = BalancedReactionScreenViewModel()
        model.navigation.nextScreen = nextScreen
        model.navigation.prevScreen = prevScreen
        self.model = model
    }

    private let model: BalancedReactionScreenViewModel

    var screen: AnyView {
        AnyView(BalancedReactionScreen(model: model))
    }
}

private class LimitingReagentScreenProvider: ScreenProvider {
    init(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) {
        let model = LimitingReagentScreenViewModel()
        model.navigation.nextScreen = nextScreen
        model.navigation.prevScreen = prevScreen
        self.model = model
    }

    private let model: LimitingReagentScreenViewModel

    var screen: AnyView {
        AnyView(LimitingReagentScreen(model: model))
    }
}

private class PrecipitationScreenProvider: ScreenProvider {
    init(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void
    ) {
        let model = PrecipitationScreenViewModel()
        model.navigation.nextScreen = nextScreen
        model.navigation.prevScreen = prevScreen
        self.model = model
    }

    private let model: PrecipitationScreenViewModel

    var screen: AnyView {
        AnyView(PrecipitationScreen(model: model))
    }
}

private class QuizScreenProvider: ScreenProvider {

    init(
        questions: QuizQuestionsList<ChemicalReactionsQuestionSet>,
        persistence: AnyQuizPersistence<ChemicalReactionsQuestionSet>,
        analytics: AnyAppAnalytics<ChemicalReactionsScreen, ChemicalReactionsQuestionSet>,
        next: @escaping () -> Void,
        prev: @escaping () -> Void
    ) {
        self.model = QuizViewModel(
            questions: questions,
            persistence: persistence,
            analytics: analytics,
            bundle: .chemicalReactions
        )
        self.model.nextScreen = next
        self.model.prevScreen = prev
    }

    let model: QuizViewModel<
        AnyQuizPersistence<ChemicalReactionsQuestionSet>,
        AnyAppAnalytics<ChemicalReactionsScreen, ChemicalReactionsQuestionSet>>

    var screen: AnyView {
        AnyView(QuizScreen(model: model))
    }
}
