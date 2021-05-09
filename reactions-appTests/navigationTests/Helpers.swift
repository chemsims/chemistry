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

private func checkPreviousValueIsReapplied<T: Equatable>(
    model: ZeroOrderReactionViewModel,
    navigation: NavigationModel<ReactionState>,
    prevValueKeyPath: KeyPath<ZeroOrderReactionViewModel, T>
) {
    var hasEnded = false
    navigation.nextScreen = { hasEnded = true }

    func checkCurrentStatementIsReapplied() {
        let previousValue = model[keyPath: prevValueKeyPath]
        navigation.next()
        if !hasEnded {
            navigation.back()
            XCTAssertEqual(model[keyPath: prevValueKeyPath], previousValue, model.firstLine)
        }
    }

    while !hasEnded {
        checkCurrentStatementIsReapplied()
        navigation.next()
    }
}
