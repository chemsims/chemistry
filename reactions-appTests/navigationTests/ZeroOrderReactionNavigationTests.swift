//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import reactions_app

class ZeroOrderReactionNavigationTests: XCTestCase {

    func testReactionInputsAreResetAndRestoredWhenReactionTypeChanges() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)

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
        model.pendingReactionSelection = .C

        nav.next()
        XCTAssertFalse(model.canSelectReaction)
        XCTAssertEqual(model.usedReactions, [.A, .C])
        nav.nextUntil(\.canSelectReaction)

        XCTAssertEqual(model.usedReactions, [.A, .C])
        XCTAssertEqual(model.pendingReactionSelection, .B)

        nav.back()
        XCTAssertFalse(model.canSelectReaction)
        nav.backUntil(\.canSelectReaction)

        XCTAssertEqual(model.usedReactions, [.A])
    }

    func testThatTheReactionToggleIsDisabledCorrectly() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)

        func canSelect() {
            XCTAssertTrue(model.canSelectReaction)
            XCTAssertTrue(model.showReactionSelection)
        }
        func cannotSelect() {
            XCTAssertFalse(model.canSelectReaction)
            XCTAssertFalse(model.showReactionSelection)
        }

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

    func testCurrentTimeAndInputSelectionStateWhenChangingReactionType() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)

        nav.nextUntil(\.canSelectReaction)
        XCTAssertTrue(model.canSelectReaction)

        nav.back()
        XCTAssertTrue(model.reactionHasEnded)
        XCTAssertFalse(model.inputsAreDisabled)

        model.currentTime = 20
        nav.next()
        XCTAssertEqual(model.currentTime!, 20)
    }

    func testPendingReactionTypeState() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)

        nav.nextUntil(\.canSelectReaction)
        XCTAssertTrue(model.canSelectReaction)
        XCTAssertEqual(model.pendingReactionSelection, .B)

        nav.next()
        XCTAssertEqual(model.selectedReaction, .B)
    }

    func testNoElementsAreHighlightedWhenGoingBackFromSelectReactionState() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)

        nav.nextUntil(\.canSelectReaction)
        nav.back()

        XCTAssertEqual(model.highlightedElements, [])
    }

    func testHalfLifeIsHighlightedWhenItIsBeingExplained() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)

        XCTAssertEqual(model.highlightedElements, [])

        nav.nextUntil {
            $0.firstLine.starts(with: "Half-life")
        }

        XCTAssertEqual(model.highlightedElements, [.halfLifeEquation])
        nav.next()
        XCTAssertEqual(model.highlightedElements, [])
        nav.back()
        XCTAssertEqual(model.highlightedElements, [.halfLifeEquation])
    }

    func testStatementsAreReappliedOnBack() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)
        doTestStatementsAreReappliedOnBack(model: model, navigation: nav)
    }

    func testHighlightedElementsAreReappliedOnBack() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)
        doTestHighlightedElementsAreReappliedOnBack(model: model, navigation: nav)
    }

    /// This test could be a little more fragile than the others, so it's worth keeping the
    /// other tests to test more specific highlighting states (e.g., that half-life is highlighted)
    func testFlowOfHighlightedElementsAndStatements() {
        let model = ZeroOrderReactionViewModel()
        let nav = navModel(model)

        func checkElements(_ expected: [OrderedReactionScreenElement]) {
            XCTAssertEqual(model.highlightedElements.sorted(), expected.sorted())
        }

        func checkStartOfLine(_ expectedStartOfLine: String) {
            XCTAssertTrue(model.firstLine.starts(with: expectedStartOfLine), model.firstLine)
        }

        func nextUntil(_ startOfLine: String) {
            nav.nextUntil { $0.firstLine.starts(with: startOfLine) }
        }

        checkElements([])

        nextUntil("The order of a reaction has to do")
        checkElements([.rateConstantEquation])

        nav.next()
        checkStartOfLine("Half-life")
        checkElements([.halfLifeEquation])

        nextUntil("For this zero order")
        // Secondary chart may be marked as highlighted too, but we don't care about it for zero order so filter it
        let elementsWithoutSecondary = model.highlightedElements.filter { $0 != .secondaryChart }
        XCTAssertEqual(elementsWithoutSecondary, [.concentrationChart])

        nav.next()
        checkStartOfLine("You can click the button")
        checkElements([.concentrationTable])

        nav.next()
        checkStartOfLine("Amazing!")
        checkElements([])
    }

    private func navModel(
        _ viewModel: ZeroOrderReactionViewModel
    ) -> NavigationModel<ReactionState> {
        let nav = ZeroOrderReactionNavigation.model(
            reaction: viewModel,
            persistence: InMemoryReactionInputPersistence()
        )
        viewModel.navigation = nav
        return nav
    }
}
