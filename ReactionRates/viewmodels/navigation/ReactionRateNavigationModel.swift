//
// Reactions App
//

import SwiftUI
import ReactionsCore

public typealias ReactionRatesNavInjector = AnyNavigationInjector<ReactionRatesScreen, ReactionsRateQuestionSet>

extension RootNavigationViewModel where Injector == ReactionRatesNavInjector {

    public static func production(
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) -> RootNavigationViewModel<ReactionRatesNavInjector> {
        model(
            using: ProductionReactionRatesInjector(),
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunchPersistence,
            analytics: analytics
        )
    }

    public static func inMemory(
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) -> RootNavigationViewModel<ReactionRatesNavInjector> {
        model(
            using: InMemoryReactionRatesInjector(),
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunchPersistence,
            analytics: analytics
        )
    }

    private static func model(
        using injector: ReactionRates.ReactionRatesInjector,
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) -> RootNavigationViewModel<ReactionRatesNavInjector> {
        ReactionRateNavigationModel.navigationModel(
            using: injector,
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunchPersistence,
            analytics: analytics
        )
    }
}

struct ReactionRateNavigationModel {

    static func navigationModel(
        using injector: ReactionRates.ReactionRatesInjector,
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) -> RootNavigationViewModel<ReactionRatesNavInjector> {
        RootNavigationViewModel(
            injector: navigationInjector(
                using: injector,
                sharePrompter: sharePrompter,
                appLaunchPersistence: appLaunchPersistence
            ),
            generalAnalytics: analytics
        )
    }

    private static func navigationInjector(
        using injector: ReactionRatesInjector,
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence
    ) -> ReactionRatesNavInjector {
        AnyNavigationInjector(
            behaviour: AnyNavigationBehavior(
                ReactionsRateNavigationBehaviour(injector: injector)
            ),
            persistence: injector.screenPersistence,
            analytics: injector.appAnalytics,
            quizPersistence: injector.quizPersistence,
            reviewPersistence: injector.reviewPersistence,
            namePersistence: injector.namePersistence,
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunchPersistence,
            allScreens: ReactionRatesScreen.allCases,
            linearScreens: linearScreens
        )
    }

    private static let linearScreens: [ReactionRatesScreen] = [
        .zeroOrderReaction,
        .zeroOrderReactionQuiz,
        .firstOrderReaction,
        .firstOrderReactionQuiz,
        .secondOrderReaction,
        .secondOrderReactionQuiz,
        .reactionComparison,
        .reactionComparisonQuiz,
        .energyProfile,
        .energyProfileQuiz,
        .finalAppScreen
    ]
}

private struct ReactionsRateNavigationBehaviour: NavigationBehaviour {

    typealias Screen = ReactionRatesScreen
    let injector: ReactionRatesInjector

    func deferCanSelect(of screen: ReactionRatesScreen) -> DeferCanSelect<ReactionRatesScreen>? {
        switch screen {
        case .zeroOrderFiling: return .canSelect(other: .firstOrderReaction)
        case .firstOrderFiling: return .canSelect(other: .secondOrderReaction)
        case .secondOrderFiling: return .canSelect(other: .reactionComparison)
        case .energyProfileFiling: return .hasCompleted(other: .energyProfileQuiz)
        default: return nil
        }
    }

    func shouldRestoreStateWhenJumpingTo(screen: ReactionRatesScreen) -> Bool {
        screen.isQuiz
    }

    func showReviewPromptOn(screen: ReactionRatesScreen) -> Bool {
        screen == .secondOrderReaction
    }

    func showMenuOn(screen: ReactionRatesScreen) -> Bool {
        screen == .finalAppScreen
    }

    func highlightedNavIcon(for screen: ReactionRatesScreen) -> ReactionRatesScreen? {
        screen == .finalAppScreen ? .zeroOrderFiling : nil
    }

    func getProvider(for screen: ReactionRatesScreen, nextScreen: @escaping () -> Void, prevScreen: @escaping () -> Void) -> ScreenProvider {
        screen.screenProvider(
            persistence: injector.reactionPersistence,
            quizPersistence: injector.quizPersistence,
            energyPersistence: injector.energyPersistence,
            analytics: injector.appAnalytics,
            next: nextScreen,
            prev: prevScreen
        )
    }
}

fileprivate extension ReactionRatesScreen {
    func screenProvider(
        persistence: ReactionInputPersistence,
        quizPersistence: AnyQuizPersistence<ReactionsRateQuestionSet>,
        energyPersistence: EnergyProfilePersistence,
        analytics: AnyAppAnalytics<ReactionRatesScreen, ReactionsRateQuestionSet>,
        next: @escaping () -> Void,
        prev: @escaping () -> Void
    ) -> ScreenProvider {
        switch self {
        case .zeroOrderReaction:
            return ZeroOrderReactionScreenProvider(persistence: persistence, next: next, prev: prev)
        case .zeroOrderReactionQuiz:
            return QuizScreenProvider(
                questions: .zeroOrderQuestions,
                persistence: quizPersistence,
                analytics: analytics,
                next: next,
                prev: prev
            )
        case .firstOrderReaction:
            return FirstOrderReactionScreenProvider(persistence: persistence, next: next, prev: prev)
        case .firstOrderReactionQuiz:
            return QuizScreenProvider(
                questions: .firstOrderQuestions,
                persistence: quizPersistence,
                analytics: analytics,
                next: next,
                prev: prev
            )
        case .secondOrderReaction:
            return SecondOrderReactionScreenProvider(persistence: persistence, next: next, prev: prev)
        case .secondOrderReactionQuiz:
            return QuizScreenProvider(
                questions: .secondOrderQuestions,
                persistence: quizPersistence,
                analytics: analytics,
                next: next,
                prev: prev
            )
        case .reactionComparison:
            return ReactionComparisonScreenProvider(persistence: persistence, next: next, prev: prev)
        case .reactionComparisonQuiz:
            return QuizScreenProvider(
                questions: .reactionComparisonQuizQuestions,
                persistence: quizPersistence,
                analytics: analytics,
                next: next,
                prev: prev
            )
        case .energyProfile:
            return EnergyProfileScreenProvider(persistence: energyPersistence, next: next, prev: prev)
        case .energyProfileFiling:
            return EnergyProfileFilingScreenProvider(persistence: energyPersistence)
        case .energyProfileQuiz:
            return QuizScreenProvider(
                questions: .energyProfileQuizQuestions,
                persistence: quizPersistence,
                analytics: analytics,
                next: next,
                prev: prev
            )
        case .zeroOrderFiling:
            return ReactionFilingScreenProvider(persistence: persistence, order: .Zero)
        case .firstOrderFiling:
            return ReactionFilingScreenProvider(persistence: persistence, order: .First)
        case .secondOrderFiling:
            return ReactionFilingScreenProvider(persistence: persistence, order: .Second)
        case .finalAppScreen:
            return FinalAppScreenProvider(
                persistence: energyPersistence,
                prev: prev
            )
        }
    }
}

private class ZeroOrderReactionScreenProvider: ScreenProvider {
    init(persistence: ReactionInputPersistence, next: @escaping () -> Void, prev: @escaping () -> Void) {
        self.persistence = persistence
        self.viewModel = ZeroOrderReactionViewModel()
        self.navigation = ZeroOrderReactionNavigation.model(reaction: viewModel, persistence: persistence)
        self.viewModel.navigation = navigation
        navigation.nextScreen = next
        navigation.prevScreen = prev
    }

    let persistence: ReactionInputPersistence
    let viewModel: ZeroOrderReactionViewModel
    let navigation: NavigationModel<ReactionState>

    var screen: AnyView {
        AnyView(ZeroOrderReactionScreen(reaction: viewModel))
    }
}

private class FirstOrderReactionScreenProvider: ScreenProvider {
    init(persistence: ReactionInputPersistence, next: @escaping () -> Void, prev: @escaping () -> Void) {
        self.persistence = persistence
        self.viewModel = FirstOrderReactionViewModel()
        self.navigation = FirstOrderReactionNavigation.model(reaction: viewModel, persistence: persistence)
        self.viewModel.navigation = navigation
        navigation.nextScreen = next
        navigation.prevScreen = prev
    }

    let persistence: ReactionInputPersistence
    let viewModel: FirstOrderReactionViewModel
    let navigation: NavigationModel<ReactionState>

    var screen: AnyView {
        AnyView(FirstOrderReactionScreen(reaction: viewModel))
    }
}

private class SecondOrderReactionScreenProvider: ScreenProvider {
    init(persistence: ReactionInputPersistence, next: @escaping () -> Void, prev: @escaping () -> Void) {
        self.persistence = persistence
        self.viewModel = SecondOrderReactionViewModel()
        self.navigation = SecondOrderReactionNavigation.model(reaction: viewModel, persistence: persistence)
        self.viewModel.navigation = navigation
        navigation.nextScreen = next
        navigation.prevScreen = prev
    }

    let persistence: ReactionInputPersistence
    let viewModel: SecondOrderReactionViewModel
    let navigation: NavigationModel<ReactionState>

    var screen: AnyView {
        AnyView(SecondOrderReactionScreen(reaction: viewModel))
    }
}

private class QuizScreenProvider: ScreenProvider {
    init(
        questions: QuizQuestionsList<ReactionsRateQuestionSet>,
        persistence: AnyQuizPersistence<ReactionsRateQuestionSet>,
        analytics: AnyAppAnalytics<ReactionRatesScreen, ReactionsRateQuestionSet>,
        next: @escaping () -> Void,
        prev: @escaping () -> Void
    ) {
        self.viewModel = QuizViewModel(
            questions: questions,
            persistence: persistence,
            analytics: analytics,
            bundle: .reactionRates
        )
        viewModel.nextScreen = next
        viewModel.prevScreen = prev
    }

    let viewModel: QuizViewModel<AnyQuizPersistence<ReactionsRateQuestionSet>, AnyAppAnalytics<ReactionRatesScreen, ReactionsRateQuestionSet>>

    var screen: AnyView {
        AnyView(QuizScreen(model: viewModel))
    }
}

private class ReactionComparisonScreenProvider: ScreenProvider {
    init(persistence: ReactionInputPersistence, next: @escaping () -> Void, prev: @escaping () -> Void) {
        let viewModel = ReactionComparisonViewModel(persistence: persistence)
        let navigation = ReactionComparisonNavigationViewModel.model(reaction: viewModel)
        navigation.nextScreen = next
        navigation.prevScreen = prev
        viewModel.navigation = navigation
        self.viewModel = viewModel
    }

    let viewModel: ReactionComparisonViewModel

    var screen: AnyView {
        AnyView(ReactionComparisonScreen(model: viewModel))
    }
}

private class EnergyProfileScreenProvider: ScreenProvider {

    init(
        persistence: EnergyProfilePersistence,
        next: @escaping () -> Void,
        prev: @escaping () -> Void
    ) {
        self.viewModel = EnergyProfileViewModel()
        self.navigation = EnergyProfileNavigationViewModel.model(viewModel, persistence: persistence)
        viewModel.navigation = navigation
        navigation.nextScreen = next
        navigation.prevScreen = prev
    }

    let navigation: NavigationModel<EnergyProfileState>
    let viewModel: EnergyProfileViewModel

    var screen: AnyView {
        AnyView(EnergyProfileScreen(navigation: navigation))
    }
}

private class EnergyProfileFilingScreenProvider: ScreenProvider {

    init(persistence: EnergyProfilePersistence) {
        self.persistence = persistence
    }

    private let persistence: EnergyProfilePersistence

    var screen: AnyView {
        AnyView(
            EnergyProfileFilingScreen(
                model: EnergyProfileFilingViewModel(
                    persistence: persistence
                )
            )
        )
    }
}

private class ReactionFilingScreenProvider: ScreenProvider {
    init(persistence: ReactionInputPersistence, order: ReactionOrder) {
        self.viewModel = ReactionFilingViewModel(persistence: persistence, order: order)
    }

    let viewModel: ReactionFilingViewModel

    var screen: AnyView {
        AnyView(ReactionFilingScreen(model: viewModel))
    }
}

private class FinalAppScreenProvider: ScreenProvider {

    init(
        persistence: EnergyProfilePersistence,
        prev: @escaping () -> Void
    ) {
        let viewModel = EnergyProfileViewModel()
        self.navigation = NavigationModel(
            model: viewModel,
            states: [FinalEnergyProfileState(persistence: persistence)]
        )
        self.navigation.prevScreen = prev
        viewModel.navigation = navigation
    }

    let navigation: NavigationModel<EnergyProfileState>

    var screen: AnyView {
        return AnyView(EnergyProfileScreen(navigation: navigation))
    }
}

private class FinalEnergyProfileState: EnergyProfileState {

    init(persistence: EnergyProfilePersistence) {
        self.persistence = persistence
        super.init(statement: EnergyProfileStatements.endOfApp)
    }

    let persistence: EnergyProfilePersistence

    override func apply(on model: EnergyProfileViewModel) {
        super.apply(on: model)
        model.highlightedElements = [.menuIcon]
        model.interactionEnabled = false
        model.particleState = .appearInBeaker
        model.usedCatalysts = Catalyst.allCases
        model.concentrationC = 1

        let input = persistence.getInput()

        model.catalystState = .selected(catalyst: input?.catalysts.last ?? .A)
        model.selectedReaction = input?.order ?? .Zero
        model.reactionState = .completed
    }
}
