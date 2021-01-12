//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class ReactionNavigationTests: XCTestCase {

    func testReactionInputsAreResetAndRestoredWhenReactionTypeChanges() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)
        print(model.canSelectReaction)

        nav.nextUntil(\.canSelectReaction)
        let t2 = model.input.inputT2!
        let c2 = model.input.inputC2!
        XCTAssertEqual(model.canSelectReaction, true)
        XCTAssertEqual(model.currentTime!, t2, accuracy: 0.001)
        XCTAssertEqual(model.usedReactions, [.A])

        nav.next()
        XCTAssertEqual(model.canSelectReaction, false)
        XCTAssertNil(model.currentTime)
        XCTAssertEqual(model.selectedReaction, .B)
        XCTAssertEqual(model.usedReactions, [.A, .B])
        XCTAssertNil(model.input.inputT2)
        XCTAssertNil(model.input.inputC2)

        nav.back()
        XCTAssertEqual(model.canSelectReaction, true)

        // Only current time uses accuracy, since it is derived from t2. t2 & c2 should be exact
        XCTAssertEqual(model.currentTime!, t2, accuracy: 0.001)
        XCTAssertEqual(model.input.inputC2!, c2)
        XCTAssertEqual(model.input.inputT2!, t2)

        nav.next()
        nav.nextUntil(\.canSelectReaction)

        let t2_2 = model.input.inputT2!
        let c2_2 = model.input.inputC2!
        XCTAssertEqual(model.canSelectReaction, true)
        XCTAssertEqual(model.currentTime!, t2_2, accuracy: 0.001)
        XCTAssertEqual(model.usedReactions, [.A, .B])

        nav.next()
        XCTAssertEqual(model.canSelectReaction, false)
        XCTAssertNil(model.input.inputT2)
        XCTAssertNil(model.input.inputC2)

        nav.back()
        XCTAssertEqual(model.canSelectReaction, true)
        XCTAssertEqual(model.currentTime!, t2_2, accuracy: 0.001)
        XCTAssertEqual(model.input.inputC2!, c2_2)
    }

    func testThatReactionTypesAreUsedUpOnNextAndReleasedOnBack() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)

        nav.nextUntil(\.canSelectReaction)
        XCTAssertEqual(model.usedReactions, [.A])
        model.selectedReaction = .C

        nav.next()
        XCTAssertFalse(model.canSelectReaction)
        XCTAssertEqual(model.usedReactions, [.A, .C])
        nav.nextUntil(\.canSelectReaction)

        XCTAssertEqual(model.usedReactions, [.A, .C])
        XCTAssertEqual(model.selectedReaction, .B)

        nav.back()
        XCTAssertFalse(model.canSelectReaction)
        nav.backUntil(\.canSelectReaction)

        XCTAssertEqual(model.usedReactions, [.A])
    }

    func testThatTheReactionToggleIsDisabledCorrectly() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)

        func canSelect() { XCTAssertTrue(model.canSelectReaction) }
        func cannotSelect() { XCTAssertFalse(model.canSelectReaction) }

        nav.nextUntil(\.canSelectReaction)
        canSelect()

        nav.back()
        cannotSelect()

        nav.next()
        canSelect()

        nav.next()
        cannotSelect()

        nav.nextUntil(\.canSelectReaction)
        canSelect()

        nav.back()
        cannotSelect()

        nav.next()
        canSelect()

        nav.next()
        cannotSelect()

        nav.back()
        canSelect()
    }

    private func navModel(
        _ viewModel: ZeroOrderReactionViewModel
    ) -> NavigationViewModel<ReactionState> {
        let nav = ZeroOrderReactionNavigation.model(
            reaction: viewModel,
            persistence: InMemoryReactionInputPersistence()
        )
        viewModel.navigation = nav
        return nav
    }
}

