//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import Equilibrium

class AqueousViewModelParametersReappliedTests: XCTestCase {

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
    }

    private func doTest<T: Equatable>(_ path: KeyPath<AqueousReactionViewModel, T>) {
        let model = AqueousReactionViewModel()
        checkPreviousValueIsReapplied(
            model: model,
            navigation: model.navigation!,
            prevValueKeyPath: path
        )
    }
}
