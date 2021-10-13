//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class LimitingReagentScreenNavigationTests: XCTestCase {

    func testParametersAreReapplied() {
        doTest(\.statement)
        doTest(\.input)
        doTest(\.equationState)
        doTest(\.highlightedElements)
    }

    private func doTest<T: Equatable>(_ path: KeyPath<LimitingReagentScreenViewModel, T>) {
        let model = LimitingReagentScreenViewModel()
        checkPreviousValueIsReapplied(
            model: model,
            navigation: model.navigation!,
            prevValueKeyPath: path
        )
    }
}

private extension LimitingReagentScreenViewModel {
    var highlightedElements: [ScreenElement] {
        highlights.elements
    }
}
