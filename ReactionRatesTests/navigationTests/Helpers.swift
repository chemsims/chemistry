//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ReactionRates

func doTestStatementsAreReappliedOnBack(
    model: ZeroOrderReactionViewModel,
    navigation: NavigationModel<ReactionState>
) {
    checkPreviousValueIsReapplied(
        model: model,
        navigation: navigation,
        prevValueKeyPath: \.statement
    )
}

func doTestHighlightedElementsAreReappliedOnBack(
    model: ZeroOrderReactionViewModel,
    navigation: NavigationModel<ReactionState>
) {
    checkPreviousValueIsReapplied(
        model: model,
        navigation: navigation,
        prevValueKeyPath: \.highlightedElements
    )
}
