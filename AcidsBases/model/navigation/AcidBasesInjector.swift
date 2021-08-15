//
// Reactions App
//

import Foundation
import ReactionsCore

protocol AcidBasesInjector {
    var titrationPersistence: TitrationInputPersistence { get }

    var screenPersistence: AnyScreenPersistence<AcidBasesScreen> { get }

    var analytics: AnyAppAnalytics<AcidBasesScreen, AcidBasesQuestionSet> { get }

    var quizPersistence: AnyQuizPersistence<AcidBasesQuestionSet> { get }

    var substancePersistence: AcidOrBasePersistence { get }

    var reviewPersistence: ReviewPromptPersistence { get }

    var namePersistence: NamePersistence { get }
}

class InMemoryAcidBasesInjector: AcidBasesInjector {

    let titrationPersistence: TitrationInputPersistence =
        InMemoryTitrationInputPersistence()

    let screenPersistence: AnyScreenPersistence<AcidBasesScreen> =
        AnyScreenPersistence(UserDefaultsScreenPersistence(prefix: userDefaultsPrefix))

    let analytics: AnyAppAnalytics<AcidBasesScreen, AcidBasesQuestionSet> =
        AnyAppAnalytics(NoOpAppAnalytics())

    let quizPersistence: AnyQuizPersistence<AcidBasesQuestionSet> =
        AnyQuizPersistence(InMemoryQuizPersistence())

    let substancePersistence: AcidOrBasePersistence =
        InMemoryAcidOrBasePersistence()

    let reviewPersistence: ReviewPromptPersistence =
        InMemoryReviewPromptPersistence()

    let namePersistence: NamePersistence =
        InMemoryNamePersistence.shared
}

class ProductionAcidBasesInjector: AcidBasesInjector {

    // Note: This is stored in-memory in production as we don't need to store it on disk
    let titrationPersistence: TitrationInputPersistence =
        InMemoryTitrationInputPersistence()

    let screenPersistence: AnyScreenPersistence<AcidBasesScreen> =
        AnyScreenPersistence(
            UserDefaultsScreenPersistence(prefix: userDefaultsPrefix)
        )

    let analytics: AnyAppAnalytics<AcidBasesScreen, AcidBasesQuestionSet> =
        AnyAppAnalytics(
            GoogleAnalytics(unitName: "acidsBases")
        )

    let quizPersistence: AnyQuizPersistence<AcidBasesQuestionSet> =
        AnyQuizPersistence(
            UserDefaultsQuizPersistence(prefix: userDefaultsPrefix)
        )

    let substancePersistence: AcidOrBasePersistence =
        UserDefaultsAcidOrBasePersistence()

    let reviewPersistence: ReviewPromptPersistence =
        UserDefaultsReviewPromptPersistence()

    let namePersistence: NamePersistence = UserDefaultsNamePersistence()
}

private let userDefaultsPrefix = "acidsBases"
