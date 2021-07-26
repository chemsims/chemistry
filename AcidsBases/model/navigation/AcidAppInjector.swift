//
// Reactions App
//

import Foundation
import ReactionsCore

protocol AcidAppInjector {
    var titrationPersistence: TitrationInputPersistence { get }

    var screenPersistence: AnyScreenPersistence<AcidAppScreen> { get }

    var analytics: AnyAppAnalytics<AcidAppScreen, AcidAppQuestionSet> { get }

    var quizPersistence: AnyQuizPersistence<AcidAppQuestionSet> { get }

    var substancePersistence: AcidOrBasePersistence { get }

    var reviewPersistence: ReviewPromptPersistence { get }

    var onboardingPersistence: OnboardingPersistence { get }

    var namePersistence: NamePersistence { get }
}

class InMemoryAcidAppInjector: AcidAppInjector {

    let titrationPersistence: TitrationInputPersistence =
        InMemoryTitrationInputPersistence()

    let screenPersistence: AnyScreenPersistence<AcidAppScreen> =
        AnyScreenPersistence(NoOpScreenPersistence())

    let analytics: AnyAppAnalytics<AcidAppScreen, AcidAppQuestionSet> =
        AnyAppAnalytics(NoOpAppAnalytics())

    let quizPersistence: AnyQuizPersistence<AcidAppQuestionSet> =
        AnyQuizPersistence(InMemoryQuizPersistence())

    let substancePersistence: AcidOrBasePersistence =
        InMemoryAcidOrBasePersistence()

    let reviewPersistence: ReviewPromptPersistence =
        InMemoryReviewPromptPersistence()

    let onboardingPersistence: OnboardingPersistence =
        InMemoryOnboardingPersistence(hasCompletedOnboarding: true)

    let namePersistence: NamePersistence =
        InMemoryNamePersistence()
}

class ProductionAcidAppInjector: AcidAppInjector {

    // Note: This is stored in-memory in production as we don't need to store it on disk
    let titrationPersistence: TitrationInputPersistence =
        InMemoryTitrationInputPersistence()

    let screenPersistence: AnyScreenPersistence<AcidAppScreen> =
        AnyScreenPersistence(
            UserDefaultsScreenPersistence(prefix: userDefaultsPrefix)
        )

    let analytics: AnyAppAnalytics<AcidAppScreen, AcidAppQuestionSet> =
        AnyAppAnalytics(
            GoogleAnalytics(unitName: "acidsBases")
        )

    let quizPersistence: AnyQuizPersistence<AcidAppQuestionSet> =
        AnyQuizPersistence(
            UserDefaultsQuizPersistence(prefix: userDefaultsPrefix)
        )

    let substancePersistence: AcidOrBasePersistence =
        UserDefaultsAcidOrBasePersistence()

    let reviewPersistence: ReviewPromptPersistence =
        UserDefaultsReviewPromptPersistence()

    let onboardingPersistence: OnboardingPersistence =
        UserDefaultsOnboardingPersistence()

    let namePersistence: NamePersistence =
        UserDefaultsNamePersistence()
}

private let userDefaultsPrefix = "acidsBases"
