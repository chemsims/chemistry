//
// Reactions App
//
  

import SwiftUI
import StoreKit

class RootNavigationViewModel: ObservableObject {

    @Published var view: AnyView
    @Published var showMenu = false
    private(set) var navigationDirection = NavigationDirection.forward

    var focusScreen: AppScreen? {
        currentScreen == .finalAppScreen ? .zeroOrderFiling : nil
    }

    private let persistence: ReactionInputPersistence
    private let quizPersistence: QuizPersistence
    private let reviewPersistence: ReviewPromptPersistence
    private let energyPersistence: EnergyProfilePersistence
    private var models = [AppScreen:ScreenProvider]()
    private(set) var currentScreen: AppScreen

    init(
        persistence: ReactionInputPersistence,
        quizPersistence: QuizPersistence,
        reviewPersistence: ReviewPromptPersistence,
        energyPersistence: EnergyProfilePersistence
    ) {
        let firstScreen = AppScreen.zeroOrderReaction
        self.currentScreen = firstScreen
        self.persistence = persistence
        self.quizPersistence = quizPersistence
        self.reviewPersistence = reviewPersistence
        self.energyPersistence = energyPersistence
        self.view = AnyView(EmptyView())
        goTo(screen: firstScreen, with: getProvider(for: firstScreen))
    }

    private var reduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    func canSelect(screen: AppScreen) -> Bool {
        return true
        switch (screen) {
        case .zeroOrderFiling: return canSelect(screen: .firstOrderReaction)
        case.firstOrderFiling: return canSelect(screen: .secondOrderReaction)
        case .secondOrderFiling: return canSelect(screen: .reactionComparison)
        case .energyProfileFiling: return persistence.hasCompleted(screen: .energyProfileQuiz)
        default:
            if let previousScreen = linearScreens.element(before: screen) {
                return persistence.hasCompleted(screen: previousScreen)
            }
            return true
        }
    }

    func canSelectFilingCabinet(order: ReactionOrder) -> Bool {
        persistence.hasCompleted(screen: order.reactionScreen)
    }

    func jumpTo(screen: AppScreen) {
        if (screen.isQuiz) {
            goToExisting(screen: screen)
        } else {
            goToFresh(screen: screen)
        }
    }

    private func goToFresh(screen: AppScreen) {
        guard screen != currentScreen else {
            return
        }
        goTo(screen: screen, with: getProvider(for: screen))
    }

    private func next() {
        if let nextScreen = linearScreens.element(after: currentScreen) {
            persistence.setCompleted(screen: currentScreen)
            goToFresh(screen: nextScreen)
        }
    }

    private func prev() {
        if let prevScreen = linearScreens.element(before: currentScreen) {
            goToExisting(screen: prevScreen)
        }
    }

    private func goToExisting(screen: AppScreen) {
        let provider = models[screen] ?? getProvider(for: screen)
        goTo(screen: screen, with: provider)
    }

    private func goTo(screen: AppScreen, with provider: ScreenProvider) {
        models[screen] = provider
        navigationDirection = screenIsAfterCurrent(nextScreen: screen) ? .forward : .back
        self.currentScreen = screen
        withAnimation(navigationAnimation) {
            self.view = provider.screen
        }
        if (screen == .finalAppScreen) {
            showMenu = true
            ReviewPrompter.requestReview(persistence: reviewPersistence)
        }
    }

    private func screenIsAfterCurrent(nextScreen: AppScreen) -> Bool {
        if let indexOfCurrent = AppScreen.allCases.firstIndex(of: currentScreen),
           let indexOfNew = AppScreen.allCases.firstIndex(of: nextScreen) {
            return indexOfNew > indexOfCurrent
        }
        return false
    }

    private func getProvider(for screen: AppScreen) -> ScreenProvider {
        screen.screenProvider(
            persistence: persistence,
            quizPersistence: quizPersistence,
            energyPersistence: energyPersistence,
            next: next,
            prev: prev,
            hideMenu: { self.showMenu = false }
        )
    }

    enum NavigationDirection {
        case forward, back
    }

    private var navigationAnimation: Animation? {
        reduceMotion ? nil : Animation.easeOut(duration: 0.35)
    }

    // The linear navigation flow. i.e, when the user clicks 'next' they will navigate through these screens, in this order
    private let linearScreens: [AppScreen] = [
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

extension ReactionOrder {
    var reactionScreen: AppScreen {
        switch (self) {
        case .Zero: return .zeroOrderReaction
        case .First: return .firstOrderReaction
        case .Second: return .secondOrderReaction
        }
    }
}

fileprivate extension AppScreen {
    func screenProvider(
        persistence: ReactionInputPersistence,
        quizPersistence: QuizPersistence,
        energyPersistence: EnergyProfilePersistence,
        next: @escaping () -> Void,
        prev: @escaping () -> Void,
        hideMenu: @escaping () -> Void
    ) -> ScreenProvider {
        switch (self) {
        case .zeroOrderReaction:
            return ZeroOrderReactionScreenProvider(persistence: persistence, next: next, prev: prev)
        case .zeroOrderReactionQuiz:
            return QuizScreenProvider(
                questions: .zeroOrderQuestions,
                persistence: quizPersistence,
                next: next,
                prev: prev
            )
        case .firstOrderReaction:
            return FirstOrderReactionScreenProvider(persistence: persistence, next: next, prev: prev)
        case .firstOrderReactionQuiz:
            return QuizScreenProvider(
                questions: .firstOrderQuestions,
                persistence: quizPersistence,
                next: next,
                prev: prev
            )
        case .secondOrderReaction:
            return SecondOrderReactionScreenProvider(persistence: persistence, next: next, prev: prev)
        case .secondOrderReactionQuiz:
            return QuizScreenProvider(
                questions: .secondOrderQuestions,
                persistence: quizPersistence,
                next: next,
                prev: prev
            )
        case .reactionComparison:
            return ReactionComparisonScreenProvider(persistence: persistence, next: next, prev: prev)
        case .reactionComparisonQuiz:
            return QuizScreenProvider(
                questions: .reactionComparisonQuizQuestions,
                persistence: quizPersistence,
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
                prev: {
                    prev()
                    hideMenu()
                }
            )
        }
    }
}

fileprivate class ZeroOrderReactionScreenProvider: ScreenProvider {
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
    let navigation: NavigationViewModel<ReactionState>

    var screen: AnyView {
        AnyView(ZeroOrderReactionScreen(reaction: viewModel))
    }
}

fileprivate class FirstOrderReactionScreenProvider: ScreenProvider {
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
    let navigation: NavigationViewModel<ReactionState>

    var screen: AnyView {
        AnyView(FirstOrderReactionScreen(reaction: viewModel))
    }
}

fileprivate class SecondOrderReactionScreenProvider: ScreenProvider {
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
    let navigation: NavigationViewModel<ReactionState>

    var screen: AnyView {
        AnyView(SecondOrderReactionScreen(reaction: viewModel))
    }
}

fileprivate class QuizScreenProvider: ScreenProvider {
    init(
        questions: QuizQuestionsList,
        persistence: QuizPersistence,
        next: @escaping () -> Void,
        prev: @escaping () -> Void
    ) {
        self.viewModel = QuizViewModel(questions: questions, persistence: persistence)
        viewModel.nextScreen = next
        viewModel.prevScreen = prev
    }

    let viewModel: QuizViewModel

    var screen: AnyView {
        AnyView(QuizScreen(model: viewModel))
    }
}

fileprivate class ReactionComparisonScreenProvider: ScreenProvider {
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

fileprivate class EnergyProfileScreenProvider: ScreenProvider {

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

    let navigation: NavigationViewModel<EnergyProfileState>
    let viewModel: EnergyProfileViewModel

    var screen: AnyView {
        AnyView(EnergyProfileScreen(navigation: navigation))
    }
}

fileprivate class EnergyProfileFilingScreenProvider: ScreenProvider {

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

fileprivate class ReactionFilingScreenProvider: ScreenProvider {
    init(persistence: ReactionInputPersistence, order: ReactionOrder) {
        self.viewModel = ReactionFilingViewModel(persistence: persistence, order: order)
    }

    let viewModel: ReactionFilingViewModel

    var screen: AnyView {
        AnyView(ReactionFilingScreen(model: viewModel))
    }
}

fileprivate class FinalAppScreenProvider: ScreenProvider {

    init(
        persistence: EnergyProfilePersistence,
        prev: @escaping () -> Void
    ) {
        let viewModel = EnergyProfileViewModel()
        self.navigation = NavigationViewModel(
            model: viewModel,
            states: [FinalEnergyProfileState(persistence: persistence)]
        )
        self.navigation.prevScreen = prev
        viewModel.navigation = navigation
    }

    let navigation: NavigationViewModel<EnergyProfileState>

    var screen: AnyView {
        return AnyView(EnergyProfileScreen(navigation: navigation))
    }
}

fileprivate class FinalEnergyProfileState: EnergyProfileState {

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
