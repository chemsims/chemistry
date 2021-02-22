//
// Reactions App
//

import XCTest
@testable import reactions_app

class FirstOrderNavigationModelTests: XCTestCase {

    func testStatementsAreReappliedOnBack() {
        let model = FirstOrderReactionViewModel()
        let nav = navModel(model)
        doTestStatementsAreReappliedOnBack(model: model, navigation: nav)
    }

    func testHighlightedElementsAreReappliedOnBack() {
        let model = FirstOrderReactionViewModel()
        let nav = navModel(model)
        doTestHighlightedElementsAreReappliedOnBack(model: model, navigation: nav)
    }

    func testHalfLifeIsHighlightedWhenItIsBeingExplained() {
        let model = FirstOrderReactionViewModel()
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

    func testLinearChartIsHighlightedWhenItIsBeingExplained() {
        let model = FirstOrderReactionViewModel()
        let nav = navModel(model)

        nav.nextUntil { $0.firstLine.starts(with: "For the previous zero order") }

        XCTAssertEqual(
            model.highlightedElements.sorted(),
            [.concentrationChart, .secondaryChart].sorted(),
            model.firstLine
        )
    }

    /// This test could be a little more fragile than the others, so it's worth keeping the
    /// other tests to test more specific highlighting states (e.g., that half-life is highlighted)
    func testFlowOfHighlightedElementsAndStatements() {
        let model = FirstOrderReactionViewModel()
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

        nextUntil("The rate constant k")
        checkElements([.rateConstantEquation])

        nav.next()
        checkElements([.rateConstantEquation])

        nav.next()
        checkStartOfLine("For a reaction with one reactant")
        checkElements([.rateEquation, .concentrationChart])

        nav.next()
        checkStartOfLine("Half-life")
        checkElements([.halfLifeEquation])

        nav.next()
        checkElements([])

        nextUntil("For the previous zero order")
        checkElements([.concentrationChart, .secondaryChart])

        nav.next()
        checkStartOfLine("For this first order reaction, rate")
        checkElements([.concentrationChart, .secondaryChart])

        nav.next()
        checkStartOfLine("Notice how [A] drops")
        checkElements([.rateCurveLhs])

        nav.next()
        checkStartOfLine("For simplification")
        checkElements([.concentrationChart, .secondaryChart])

        nav.next()
        checkStartOfLine("For this first order reaction, the resultant")
        checkElements([.concentrationChart, .secondaryChart])

        nav.next()
        checkStartOfLine("Amazing!")
        checkElements([])
    }

    private func navModel(
        _ viewModel: FirstOrderReactionViewModel
    ) -> NavigationViewModel<ReactionState> {
        let nav = FirstOrderReactionNavigation.model(
            reaction: viewModel,
            persistence: InMemoryReactionInputPersistence()
        )
        viewModel.navigation = nav
        return nav
    }
}
