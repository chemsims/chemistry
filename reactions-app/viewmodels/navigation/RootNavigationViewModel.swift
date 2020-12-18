//
// Reactions App
//
  

import SwiftUI

class RootNavigationViewModel: ObservableObject {

    @Published var view: AnyView

    private let persistence: ReactionInputPersistence

    private var zeroOrderViewModel: ZeroOrderReactionViewModel?
    private var zeroOrderNavigation: NavigationViewModel<ReactionState>?

    private var firstOrderViewModel: FirstOrderReactionViewModel?
    private var firstOrderNavigation: NavigationViewModel<ReactionState>?

    private var secondOrderViewModel: SecondOrderReactionViewModel?
    private var secondOrderNavigation: NavigationViewModel<ReactionState>?

    private var comparisonViewModel: ReactionComparisonViewModel?
    private var comparisonNavigation: NavigationViewModel<ReactionComparisonState>?

    private var zeroOrderQuizViewModel: QuizViewModel?
    private var firstOrderQuizViewModel: QuizViewModel?
    private var secondOrderQuizViewModel: QuizViewModel?
    private var comparisonOrderQuizViewModel: QuizViewModel?
    private var energyProfileQuizViewModel: QuizViewModel?

    init(
        persistence: ReactionInputPersistence
    ) {
        self.view = AnyView(EmptyView())
        self.persistence = persistence
        goToEnergyProfile()
    }

    func goToZeroOrder() {
        let reaction = zeroOrderViewModel ?? ZeroOrderReactionViewModel()
        let navigation = zeroOrderNavigation ?? ZeroOrderReactionNavigation.model(reaction: reaction, persistence: persistence)
        self.zeroOrderViewModel = reaction
        self.zeroOrderNavigation = navigation
        self.view = AnyView(ZeroOrderReactionScreen(reaction: reaction, navigation: navigation))
        navigation.nextScreen = { self.goToZeroOrderQuiz(restoreState: false) }
    }

    func goToFirstOrder() {
        let reaction = firstOrderViewModel ?? FirstOrderReactionViewModel()
        let navigation = firstOrderNavigation ?? FirstOrderReactionNavigation.model(reaction: reaction, persistence: persistence)
        self.firstOrderViewModel = reaction
        self.firstOrderNavigation = navigation
        navigation.prevScreen = { self.goToZeroOrderQuiz(restoreState: true) }
        navigation.nextScreen = { self.goToFirstOrderQuiz(restoreState: false) }
        self.view = AnyView(FirstOrderReactionScreen(reaction: reaction, navigation: navigation))
    }

    func goToSecondOrder() {
        let reaction = secondOrderViewModel ?? SecondOrderReactionViewModel()
        let navigation = secondOrderNavigation ?? SecondOrderReactionNavigation.model(reaction: reaction, persistence: persistence)
        self.secondOrderViewModel = reaction
        self.secondOrderNavigation = navigation
        navigation.prevScreen = { self.goToFirstOrderQuiz(restoreState: true) }
        navigation.nextScreen = { self.goToSecondOrderQuiz(restoreState: false) }

        // Reset these models in case returning to second order
        self.comparisonViewModel = nil
        self.comparisonNavigation = nil

        self.view = AnyView(SecondOrderReactionScreen(reaction: reaction, navigation: navigation))
    }

    func goToComparison() {
        let reaction = comparisonViewModel ?? ReactionComparisonViewModel(persistence: persistence)
        let navigation = comparisonNavigation ?? ReactionComparisonNavigationViewModel.model(reaction: reaction)
        self.comparisonViewModel = reaction
        self.comparisonNavigation = navigation
        navigation.prevScreen = { self.goToSecondOrderQuiz(restoreState: true) }
        navigation.nextScreen = { self.goToComparisonQuiz(restoreState: false) }
        self.view = AnyView(ReactionComparisonScreen(navigation: navigation))
    }

    func goToEnergyProfile() {
        let model = EnergyProfileViewModel()
        let navigation = EnergyProfileNavigationViewModel.model(model)
        navigation.prevScreen = { self.goToComparisonQuiz(restoreState: true) }
        navigation.nextScreen = { self.goToEnergyProfileQuiz(restoreState: false) }
        model.navigation = navigation

        let view = EnergyProfileScreen(navigation: navigation)
        self.view = AnyView(view)
    }

    private func goToZeroOrderQuiz(restoreState: Bool) {
        let model = restoreState ? zeroOrderQuizViewModel ?? QuizViewModel() : QuizViewModel()
        zeroOrderQuizViewModel = model
        model.prevScreen = goToZeroOrder
        model.nextScreen = goToFirstOrder
        self.view = AnyView(QuizScreen(model: model))
    }

    private func goToFirstOrderQuiz(restoreState: Bool) {
        let model = restoreState ? firstOrderQuizViewModel ?? QuizViewModel() : QuizViewModel()
        firstOrderQuizViewModel = model
        model.prevScreen = goToFirstOrder
        model.nextScreen = goToSecondOrder
        self.view = AnyView(QuizScreen(model: model))
    }

    private func goToSecondOrderQuiz(restoreState: Bool) {
        let model = restoreState ? secondOrderQuizViewModel ?? QuizViewModel() : QuizViewModel()
        secondOrderQuizViewModel = model
        model.prevScreen = goToSecondOrder
        model.nextScreen = goToComparison
        self.view = AnyView(QuizScreen(model: model))
    }

    private func goToComparisonQuiz(restoreState: Bool) {
        let model = restoreState ? comparisonOrderQuizViewModel ?? QuizViewModel() : QuizViewModel()
        comparisonOrderQuizViewModel = model
        model.prevScreen = goToComparison
        model.nextScreen = goToEnergyProfile
        self.view = AnyView(QuizScreen(model: model))
    }

    private func goToEnergyProfileQuiz(restoreState: Bool) {
        let model = restoreState ? energyProfileQuizViewModel ?? QuizViewModel() : QuizViewModel()
        energyProfileQuizViewModel = model
        model.prevScreen = goToEnergyProfile
        self.view = AnyView(QuizScreen(model: model))
    }
}
