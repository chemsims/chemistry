//
// Reactions App
//

import XCTest
@testable import reactions_app

class ReactionComparisonViewModelTests: XCTestCase {

    func testCannotProgressNextUntilReactionsHaveBeenCorrectlyIdentifiedOnce() {
        let persistence = InMemoryReactionInputPersistence()
        let model = ReactionComparisonViewModel(persistence: persistence)
        let navigation = ReactionComparisonNavigationViewModel.model(reaction: model)
        model.navigation = navigation

        navigation.nextUntil(\.canDragOrders)

        model.next()
        XCTAssertTrue(model.canDragOrders)
        XCTAssertFalse(model.reactionHasEnded)

        model.addToCorrectSelection(order: .Zero)
        model.addToCorrectSelection(order: .First)
        model.addToCorrectSelection(order: .Second)

        model.next()
        XCTAssertTrue(model.reactionHasEnded)

        model.back()
        XCTAssertFalse(model.reactionHasEnded)

        model.next()
        XCTAssertTrue(model.reactionHasEnded)
    }

}
