//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import reactions_app

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
