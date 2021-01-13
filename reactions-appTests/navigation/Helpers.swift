//
// Reactions App
//
  

import XCTest
@testable import reactions_app


func doTestStatementsAreReappliedOnBack(
    model: ZeroOrderReactionViewModel,
    navigation: NavigationViewModel<ReactionState>
) {
    checkPreviousValueIsReapplied(
        model: model,
        navigation: navigation,
        prevValueKeyPath: \.statement
    )
}

func doTestHighlightedElementsAreReappliedOnBack(
    model: ZeroOrderReactionViewModel,
    navigation: NavigationViewModel<ReactionState>
) {
    checkPreviousValueIsReapplied(
        model: model,
        navigation: navigation,
        prevValueKeyPath: \.highlightedElements
    )
}

private func checkPreviousValueIsReapplied<T: Equatable>(
    model: ZeroOrderReactionViewModel,
    navigation: NavigationViewModel<ReactionState>,
    prevValueKeyPath: KeyPath<ZeroOrderReactionViewModel, T>
) {
    var hasEnded = false
    navigation.nextScreen = { hasEnded = true }

    func checkCurrentStatementIsReapplied() {
        let previousValue = model[keyPath: prevValueKeyPath]
        navigation.next()
        if (!hasEnded) {
            navigation.back()
            XCTAssertEqual(model[keyPath: prevValueKeyPath], previousValue)
        }
    }

    while(!hasEnded) {
        checkCurrentStatementIsReapplied()
        navigation.next()
    }
}
