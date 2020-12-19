//
// Reactions App
//
  

import SwiftUI

class RootNavigationViewModel: ObservableObject {

    @Published var view: AnyView

    private let persistence: ReactionInputPersistence
    private var models = [AppScreen:ScreenProvider]()
    private var currentScreen: AppScreen

    init(
        persistence: ReactionInputPersistence
    ) {
        let firstScreen = AppScreen.zeroOrderReaction
        self.currentScreen = firstScreen
        self.persistence = persistence
        self.view = AnyView(EmptyView())
        goToFresh(screen: firstScreen)
    }

    func goToFresh(screen: AppScreen) {
        let provider = screen.screenProvider(persistence: persistence, next: next, prev: prev)
        goTo(screen: screen, with: provider)
    }

    private func next() {
        if let nextScreen = screenOrdering.element(after: currentScreen) {
            goToFresh(screen: nextScreen)
        }
    }

    private func prev() {
        if let prevScreen = screenOrdering.element(before: currentScreen) {
            let provider = models[prevScreen] ?? prevScreen.screenProvider(persistence: persistence, next: next, prev: prev)
            goTo(screen: prevScreen, with: provider)
        }
    }

    private func goTo(screen: AppScreen, with provider: ScreenProvider) {
        models[screen] = provider
        self.view = provider.screen
        self.currentScreen = screen
    }

    private var screenOrdering: [AppScreen] {
        AppScreen.allCases
    }
}

extension AppScreen {
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
