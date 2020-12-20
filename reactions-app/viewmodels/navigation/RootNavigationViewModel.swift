//
// Reactions App
//
  

import SwiftUI

class RootNavigationViewModel: ObservableObject {

    @Published var view: AnyView
    private(set) var navigationDirection = NavigationDirection.forward

    private let persistence: ReactionInputPersistence
    private var models = [AppScreen:ScreenProvider]()
    private(set) var currentScreen: AppScreen

    init(
        persistence: ReactionInputPersistence
    ) {
        let firstScreen = AppScreen.firstOrderReaction
        self.currentScreen = firstScreen
        self.persistence = persistence
        self.view = AnyView(EmptyView())
        let provider = firstScreen.screenProvider(persistence: persistence, next: next, prev: prev)
        goTo(screen: firstScreen, with: provider)
    }

    private var reduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    func canSelect(screen: AppScreen) -> Bool {
        if let previousScreen = linearScreens.element(before: screen) {
            return persistence.hasCompleted(screen: previousScreen)
        }
        return true
    }

    func canSelectFilingCabinet(order: ReactionOrder) -> Bool {
        persistence.hasCompleted(screen: order.reactionScreen)
    }

    func goToFresh(screen: AppScreen) {
        guard screen != currentScreen else {
            return
        }
        let provider = screen.screenProvider(persistence: persistence, next: next, prev: prev)
        goTo(screen: screen, with: provider)
    }

    private func next() {
        if let nextScreen = linearScreens.element(after: currentScreen) {
            persistence.setCompleted(screen: currentScreen)
            goToFresh(screen: nextScreen)
        }
    }

    private func prev() {
        if let prevScreen = linearScreens.element(before: currentScreen) {
            let provider = models[prevScreen] ?? prevScreen.screenProvider(persistence: persistence, next: next, prev: prev)
            goTo(screen: prevScreen, with: provider)
        }
    }

    private func goTo(screen: AppScreen, with provider: ScreenProvider) {
        models[screen] = provider
        navigationDirection = screenIsAfterCurrent(nextScreen: screen) ? .forward : .back
        self.currentScreen = screen
        withAnimation(navigationAnimation) {
            self.view = provider.screen
        }
    }

    private func screenIsAfterCurrent(nextScreen: AppScreen) -> Bool {
        if let indexOfCurrent = AppScreen.allCases.firstIndex(of: currentScreen),
           let indexOfNew = AppScreen.allCases.firstIndex(of: nextScreen) {
            return indexOfNew > indexOfCurrent
        }
        return false
    }

    enum NavigationDirection {
        case forward, back
    }

    private var navigationAnimation: Animation? {
        reduceMotion ? nil : Animation.easeOut(duration: 0.25)
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
        .energyProfileQuiz
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
        next: @escaping () -> Void,
        prev: @escaping () -> Void
    ) -> ScreenProvider {
        switch (self) {
        case .zeroOrderReaction:
            return ZeroOrderReactionScreenProvider(persistence: persistence, next: next, prev: prev)
        case .zeroOrderReactionQuiz:
            return QuizScreenProvider(next: next, prev: prev)
        case .firstOrderReaction:
            return FirstOrderReactionScreenProvider(persistence: persistence, next: next, prev: prev)
        case .firstOrderReactionQuiz:
            return QuizScreenProvider(next: next, prev: prev)
        case .secondOrderReaction:
            return SecondOrderReactionScreenProvider(persistence: persistence, next: next, prev: prev)
        case .secondOrderReactionQuiz:
            return QuizScreenProvider(next: next, prev: prev)
        case .reactionComparison:
            return ReactionComparisonScreenProvider(persistence: persistence, next: next, prev: prev)
        case .reactionComparisonQuiz:
            return QuizScreenProvider(next: next, prev: prev)
        case .energyProfile:
            return EnergyProfileScreenProvider(next: next, prev: prev)
        case .energyProfileQuiz:
            return QuizScreenProvider(next: next, prev: prev)
        case .zeroOrderFiling:
            return ReactionFilingScreenProvider(persistence: persistence, order: .Zero)
        case .firstOrderFiling:
            return ReactionFilingScreenProvider(persistence: persistence, order: .First)
        case .secondOrderFiling:
            return ReactionFilingScreenProvider(persistence: persistence, order: .Second)
        }
    }
}

fileprivate class ZeroOrderReactionScreenProvider: ScreenProvider {
    init(persistence: ReactionInputPersistence, next: @escaping () -> Void, prev: @escaping () -> Void) {
        self.persistence = persistence
        self.viewModel = ZeroOrderReactionViewModel()
        self.navigation = ZeroOrderReactionNavigation.model(reaction: viewModel, persistence: persistence)
        navigation.nextScreen = next
        navigation.prevScreen = prev
    }

    let persistence: ReactionInputPersistence
    let viewModel: ZeroOrderReactionViewModel
    let navigation: NavigationViewModel<ReactionState>

    var screen: AnyView {
        AnyView(ZeroOrderReactionScreen(reaction: viewModel, navigation: navigation))
    }
}

fileprivate class FirstOrderReactionScreenProvider: ScreenProvider {
    init(persistence: ReactionInputPersistence, next: @escaping () -> Void, prev: @escaping () -> Void) {
        self.persistence = persistence
        self.viewModel = FirstOrderReactionViewModel()
        self.navigation = FirstOrderReactionNavigation.model(reaction: viewModel, persistence: persistence)
        navigation.nextScreen = next
        navigation.prevScreen = prev
    }

    let persistence: ReactionInputPersistence
    let viewModel: FirstOrderReactionViewModel
    let navigation: NavigationViewModel<ReactionState>

    var screen: AnyView {
        AnyView(FirstOrderReactionScreen(reaction: viewModel, navigation: navigation))
    }
}

fileprivate class SecondOrderReactionScreenProvider: ScreenProvider {
    init(persistence: ReactionInputPersistence, next: @escaping () -> Void, prev: @escaping () -> Void) {
        self.persistence = persistence
        self.viewModel = SecondOrderReactionViewModel()
        self.navigation = SecondOrderReactionNavigation.model(reaction: viewModel, persistence: persistence)
        navigation.nextScreen = next
        navigation.prevScreen = prev
    }

    let persistence: ReactionInputPersistence
    let viewModel: SecondOrderReactionViewModel
    let navigation: NavigationViewModel<ReactionState>

    var screen: AnyView {
        AnyView(SecondOrderReactionScreen(reaction: viewModel, navigation: navigation))
    }
}

fileprivate class QuizScreenProvider: ScreenProvider {
    init(next: @escaping () -> Void, prev: @escaping () -> Void) {
        self.viewModel = QuizViewModel()
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
        navigation = ReactionComparisonNavigationViewModel.model(reaction: viewModel)
        navigation.nextScreen = next
        navigation.prevScreen = prev
    }

    let navigation: NavigationViewModel<ReactionComparisonState>

    var screen: AnyView {
        AnyView(ReactionComparisonScreen(navigation: navigation))
    }
}

fileprivate class EnergyProfileScreenProvider: ScreenProvider {

    init(next: @escaping () -> Void, prev: @escaping () -> Void) {
        let viewModel = EnergyProfileViewModel()
        self.navigation = EnergyProfileNavigationViewModel.model(viewModel)
        navigation.nextScreen = next
        navigation.prevScreen = prev
    }

    let navigation: NavigationViewModel<EnergyProfileState>

    var screen: AnyView {
        AnyView(EnergyProfileScreen(navigation: navigation))
    }
}

fileprivate class ReactionFilingScreenProvider: ScreenProvider {
    init(persistence: ReactionInputPersistence, order: ReactionOrder) {
        self.viewModel = ReactionFilingViewModel(persistence: persistence, initialOrder: order)
    }

    let viewModel: ReactionFilingViewModel

    var screen: AnyView {
        AnyView(ReactionFilingScreen(model: viewModel))
    }
}
