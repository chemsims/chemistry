//
// Reactions App
//

import XCTest
@testable import Equilibrium

class GaseousViewModelParametersReappliedTests: XCTestCase {

    func testParametersAreReapplied() {
        doTest(\.statement)
        doTest(\.highlightedElements.elements)
        doTest(\.inputState)
        doTest(\.reactionSelectionIsToggled)
        doTest(\.canSetCurrentTime)
        doTest(\.showQuotientLine)
        doTest(\.showConcentrationLines)
        doTest(\.showEquationTerms)
        doTest(\.reactionDefinitionDirection)
        doTest(\.showFlame)
    }

    private func doTest<T: Equatable>(_ path: KeyPath<GaseousReactionViewModel, T>) {
        let model = GaseousReactionViewModel()
        checkPreviousValueIsReapplied(
            model: model,
            navigation: model.navigation!,
            prevValueKeyPath: path
        )
    }
}
