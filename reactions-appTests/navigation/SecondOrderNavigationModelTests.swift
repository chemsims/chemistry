//
// Reactions App
//


import XCTest
@testable import reactions_app

class SecondOrderNavigationModelTests: XCTestCase {

    func testStatementsAreReappliedOnBack() {
        let model = SecondOrderReactionViewModel()
        let nav = navModel(model)
        doTestStatementsAreReappliedOnBack(model: model, navigation: nav)
    }

    func testHighlightedElementsAreReappliedOnBack() {
        let model = SecondOrderReactionViewModel()
        let nav = navModel(model)
        doTestHighlightedElementsAreReappliedOnBack(model: model, navigation: nav)
    }

    func testHalfLifeIsHighlightedWhenItIsBeingExplained() {
        let model = SecondOrderReactionViewModel()
        let nav = navModel(model)

        XCTAssertEqual(model.highlightedElements, [])

        nav.nextUntil {
            $0.statement.first!.content.first!.content.starts(with: "Half-life")
        }

        XCTAssertEqual(model.highlightedElements, [.halfLifeEquation])
        nav.next()
        XCTAssertEqual(model.highlightedElements, [])
        nav.back()
        XCTAssertEqual(model.highlightedElements, [.halfLifeEquation])
    }

    private func navModel(
        _ viewModel: SecondOrderReactionViewModel
    ) -> NavigationViewModel<ReactionState> {
        let nav = SecondOrderReactionNavigation.model(
            reaction: viewModel,
            persistence: InMemoryReactionInputPersistence()
        )
        viewModel.navigation = nav
        return nav
    }
}
