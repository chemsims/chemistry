//
// Reactions App
//

import XCTest
import ReactionsCore
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

    /// This test could be a little more fragile than the others, so it's worth keeping the
    /// other tests to test more specific highlighting states (e.g., that half-life is highlighted)
    func testFlowOfHighlightedElementsAndStatements() {
        let model = SecondOrderReactionViewModel()
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

        nextUntil("For this reaction,")
        checkElements([.rateConstantEquation])

        nav.next()
        checkStartOfLine("For a reaction with one reactant it's usually")
        checkElements([.concentrationChart, .rateEquation])

        nav.next()
        checkStartOfLine("Half-life")
        checkElements([.halfLifeEquation])

        nextUntil("For this second order reaction, rate")
        checkElements([.concentrationChart, .secondaryChart])

        nav.next()
        checkStartOfLine("Notice how [A]")
        checkElements([.rateCurveLhs])

        nav.next()
        checkStartOfLine("Subsequently, towards the end")
        checkElements([.rateCurveRhs])

        nav.next()
        checkStartOfLine("For example,")
        checkElements([.concentrationChart, .secondaryChart])

        nav.next()
        checkStartOfLine("Since 0.1 is less")
        checkElements([.concentrationChart, .secondaryChart])

        nav.next()
        checkStartOfLine("For this second order reaction")
        checkElements([.concentrationChart, .secondaryChart])

        nav.next()
        checkStartOfLine("Amazing!")
        checkElements([])
    }

    private func navModel(
        _ viewModel: SecondOrderReactionViewModel
    ) -> NavigationModel<ReactionState> {
        let nav = SecondOrderReactionNavigation.model(
            reaction: viewModel,
            persistence: InMemoryReactionInputPersistence()
        )
        viewModel.navigation = nav
        return nav
    }
}
