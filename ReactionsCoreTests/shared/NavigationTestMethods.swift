//
// Reactions App
//

import XCTest
import ReactionsCore

public func checkPreviousValueIsReapplied<Model, State, Field: Equatable>(
    model: Model,
    navigation: NavigationModel<State>,
    prevValueKeyPath: KeyPath<Model, Field>
) {
    var hasEnded = false
    navigation.nextScreen = { hasEnded = true }

    var i = 0

    func checkCurrentStatementIsReapplied() {
        let previousValue = model[keyPath: prevValueKeyPath]
        navigation.next()
        if !hasEnded {
            navigation.back()
            XCTAssertEqual(model[keyPath: prevValueKeyPath], previousValue, "Failed on state \(i)")
        }
        i += 1
    }

    while !hasEnded {
        checkCurrentStatementIsReapplied()
        navigation.next()
    }
}
