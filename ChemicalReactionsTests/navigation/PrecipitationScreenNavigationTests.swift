//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ChemicalReactions

class PrecipitationScreenNavigationTests: XCTestCase {

    func testParametersAreReapplied() {
        doTest(\.statement)
        doTest(\.input)
        doTest(\.equationState)
        doTest(\.highlightedElements)
        doTest(\.showUnknownMetal)
    }

    private func doTest<T: Equatable>(_ path: KeyPath<PrecipitationScreenViewModel, T>) {
        let model = PrecipitationScreenViewModel()
        checkPreviousValueIsReapplied(
            model: model,
            navigation: model.navigation!,
            prevValueKeyPath: path
        )
    }
}

private extension PrecipitationScreenViewModel {
    var highlightedElements: [ScreenElement] {
        highlights.elements
    }
}
