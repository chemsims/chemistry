//
// Reactions App
//

import Foundation
import ReactionsCore

protocol ChemicalReactionsInjector {

    var screenPersistence: AnyScreenPersistence<ChemicalReactionsScreen> { get }

    var analytics: AnyAppAnalytics<ChemicalReactionsScreen, ChemicalReactionsQuestionSet> { get }

    var quizPersistence: AnyQuizPersistence<ChemicalReactionsQuestionSet> { get }

    var reviewPersistence: ReviewPromptPersistence { get }

    var namePersistence: NamePersistence { get }

    var precipitationPersistence: PrecipitationInputPersistence { get }
}

class ProductionChemicalReactionsInjector: ChemicalReactionsInjector {
    let screenPersistence: AnyScreenPersistence<ChemicalReactionsScreen> =
        AnyScreenPersistence(
            UserDefaultsScreenPersistence(prefix: userDefaultsPrefix)
        )

    let analytics: AnyAppAnalytics<ChemicalReactionsScreen, ChemicalReactionsQuestionSet> =
        AnyAppAnalytics(
            GoogleAnalytics(unitName: "chemicalReactions")
        )

    let quizPersistence: AnyQuizPersistence<ChemicalReactionsQuestionSet> =
        AnyQuizPersistence(
            UserDefaultsQuizPersistence(prefix: userDefaultsPrefix)
        )

    let reviewPersistence: ReviewPromptPersistence = UserDefaultsReviewPromptPersistence()

    let namePersistence: NamePersistence = UserDefaultsNamePersistence()

    let precipitationPersistence: PrecipitationInputPersistence = PrecipitationInputPersistence()
}

class InMemoryChemicalReactionsInjector: ChemicalReactionsInjector {
    let screenPersistence: AnyScreenPersistence<ChemicalReactionsScreen> =
        AnyScreenPersistence(
            UserDefaultsScreenPersistence(prefix: userDefaultsPrefix)
        )

    let analytics: AnyAppAnalytics<ChemicalReactionsScreen, ChemicalReactionsQuestionSet> =
        AnyAppAnalytics(NoOpAppAnalytics())

    let quizPersistence: AnyQuizPersistence<ChemicalReactionsQuestionSet> =
        AnyQuizPersistence(InMemoryQuizPersistence())

    let reviewPersistence: ReviewPromptPersistence = UserDefaultsReviewPromptPersistence()

    let namePersistence: NamePersistence = UserDefaultsNamePersistence()

    let precipitationPersistence: PrecipitationInputPersistence = PrecipitationInputPersistence()
}

private let userDefaultsPrefix = "chemical-reactions"
