//
// Reactions App
//

import SwiftUI
import ReactionsCore

public typealias AcidAppNavInjector = AnyNavigationInjector<AcidBasesScreen, AcidBasesQuestionSet>

extension RootNavigationViewModel where Injector == AcidAppNavInjector {

    public static func production(
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) -> RootNavigationViewModel<AcidAppNavInjector> {
        model(
            using: ProductionAcidBasesInjector(),
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunchPersistence,
            analytics: analytics
        )
    }

    public static func inMemory(
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) -> RootNavigationViewModel<AcidAppNavInjector> {
        model(
            using: InMemoryAcidBasesInjector(),
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunchPersistence,
            analytics: analytics
        )
    }

    private static func model(
        using injector: AcidBasesInjector,
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) -> RootNavigationViewModel<AcidAppNavInjector> {
        AcidBasesNavigationModel.model(
            injector: injector,
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunchPersistence,
            analytics: analytics
        )
    }
}

struct AcidBasesNavigationModel {
    private init() { }

    static func model(
        injector: AcidBasesInjector,
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) -> RootNavigationViewModel<AcidAppNavInjector> {
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
        using appInjector: AcidBasesInjector,
        sharePrompter: SharePrompter,
        appLaunchPersistence: AppLaunchPersistence
    ) -> AcidAppNavInjector {
        AnyNavigationInjector(
            behaviour: AnyNavigationBehavior(
                AcidAppNavigationBehaviour(injector: appInjector)
            ),
            persistence: appInjector.screenPersistence,
            analytics: appInjector.analytics,
            quizPersistence: appInjector.quizPersistence,
            reviewPersistence: appInjector.reviewPersistence,
            namePersistence: appInjector.namePersistence,
            sharePrompter: sharePrompter,
            appLaunchPersistence: appLaunchPersistence,
            allScreens: AcidBasesScreen.allCases,
            linearScreens: AcidBasesScreen.allCases
        )
    }

    private let linearScreens: [AcidBasesScreen] =
        AcidBasesScreen.allCases.filter { $0 != .finalAppScreen }
}

private struct AcidAppNavigationBehaviour: NavigationBehaviour {
    typealias Screen = AcidBasesScreen

    let injector: AcidBasesInjector

    func deferCanSelect(of screen: AcidBasesScreen) -> DeferCanSelect<AcidBasesScreen>? {
       nil
    }

    func shouldRestoreStateWhenJumpingTo(screen: AcidBasesScreen) -> Bool {
        false
    }

    func showReviewPromptOn(screen: AcidBasesScreen) -> Bool {
        screen == .finalAppScreen
    }

    func showMenuOn(screen: AcidBasesScreen) -> Bool {
        screen == .finalAppScreen
    }

    func highlightedNavIcon(for screen: AcidBasesScreen) -> AcidBasesScreen? {
        nil
    }

    func getProvider(
        for screen: AcidBasesScreen,
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

fileprivate extension AcidBasesScreen {
    func getProvider(
        nextScreen: @escaping () -> Void,
        prevScreen: @escaping () -> Void,
        injector: AcidBasesInjector
    ) -> ScreenProvider {

        func quiz(_ questions: QuizQuestionsList<AcidBasesQuestionSet>) -> ScreenProvider {
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
                titrationPersistence: injector.titrationPersistence,
                namePersistence: injector.namePersistence
            )

        case .introductionQuiz:
            return quiz(.introduction)

        case .bufferQuiz:
            return quiz(.buffer)

        case .titrationQuiz:
            return quiz(.titration)

        case .finalAppScreen:
            return FinalScreenProvider(
                titrationPersistence: injector.titrationPersistence,
                namePersistence: injector.namePersistence,
                prev: prevScreen
            )
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
        titrationPersistence: TitrationInputPersistence,
        namePersistence: NamePersistence
    ) {
        self.model = TitrationViewModel(
            titrationPersistence: titrationPersistence,
            namePersistence: namePersistence
        )
        self.model.navigation.nextScreen = nextScreen
        self.model.navigation.prevScreen = prevScreen
    }

    private let model: TitrationViewModel

    var screen: AnyView {
        AnyView(TitrationScreen(model: model))
    }
}

private class QuizScreenProvider: ScreenProvider {
    init(
        questions: QuizQuestionsList<AcidBasesQuestionSet>,
        persistence: AnyQuizPersistence<AcidBasesQuestionSet>,
        analytics: AnyAppAnalytics<AcidBasesScreen, AcidBasesQuestionSet>,
        next: @escaping () -> Void,
        prev: @escaping () -> Void
    ) {
        self.model = QuizViewModel(
            questions: questions,
            persistence: persistence,
            analytics: analytics,
            bundle: .acidBases
        )
        self.model.nextScreen = next
        self.model.prevScreen = prev
    }

    let model: QuizViewModel<
        AnyQuizPersistence<AcidBasesQuestionSet>,
        AnyAppAnalytics<AcidBasesScreen, AcidBasesQuestionSet>
    >

    var screen: AnyView {
        AnyView(QuizScreen(model: model))
    }
}

private class FinalScreenProvider: ScreenProvider {
    init(
        titrationPersistence: TitrationInputPersistence,
        namePersistence: NamePersistence,
        prev: @escaping () -> Void
    ) {
        let model = TitrationViewModel(
            titrationPersistence: titrationPersistence,
            namePersistence: namePersistence
        )
        let navigation = NavigationModel<TitrationScreenState>.init(model: model, states: [FinalTitrationScreenState()])
        navigation.prevScreen = prev
        model.navigation = navigation

        self.model = model
    }

    let model: TitrationViewModel

    var screen: AnyView {
        AnyView(TitrationScreen(model: model))
    }

}

private class FinalTitrationScreenState: TitrationScreenState {

    override func apply(on model: TitrationViewModel) {
        model.statement = TitrationStatements.endOfApp
        model.inputState = .none
        model.highlights.clear()
        model.equationState = .weakBasePostEPPostAddingTitrant
        model.substanceSelectionIsToggled = false
        model.macroBeakerState = .weakTitrant
        model.showTitrantFill = true
        model.showPhString = true

        if let input = model.titrationPersistence.input {
            model.substance = input.weakBase
            model.rows = CGFloat(input.weakBaseBeakerRows)

            setComponents(model)

            let weakModel = model.components.weakSubstancePreparationModel
            weakModel.incrementSubstance(count: input.weakBaseSubstanceAdded)
            weakModel.titrantMolarity = input.titrantMolarity

        } else {
            model.substance = .weakBases.first!

            setComponents(model)

            let weakModel = model.components.weakSubstancePreparationModel
            weakModel.incrementSubstance(count: weakModel.maxSubstance)
        }

        goToEndOfTitration(model)
    }

    private func setComponents(
        _ model: TitrationViewModel
    ) {
        model.components = TitrationComponentState(
            initialStrongSubstance: model.substance,
            initialWeakSubstance: model.substance,
            initialTitrant: .hydrogenChloride,
            cols: model.cols,
            rows: Int(model.rows),
            initialSubstance: .weakBase
        )
    }

    private func goToEndOfTitration(_ model: TitrationViewModel) {
        model.components.assertGoTo(state: .init(substance: .weakBase, phase: .preEP))
        model.components.weakSubstancePreEPModel.titrantLimit = .equivalencePoint
        model.components.weakSubstancePreEPModel.incrementTitrant(count: model.components.weakSubstancePreEPModel.maxTitrant)

        model.components.assertGoTo(state: .init(substance: .weakBase, phase: .postEP))

        let postEPModel = model.components.weakSubstancePostEPModel
        postEPModel.incrementTitrant(count: postEPModel.maxTitrant)

        // We copy the reaction progress model so that the animation doesn't replay when
        // toggling the reaction progress on final screen
        postEPModel.reactionProgress = postEPModel.reactionProgress.copy()
    }
}
