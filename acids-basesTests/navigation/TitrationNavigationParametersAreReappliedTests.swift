//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

class TitrationNavigationParametersAreReappliedTests: XCTestCase {

    func testParametersAreReapplied() {
        doTest(\.statement)
        doTest(\.inputState)
        doTest(\.equationState)
        doTest(\.showTitrantFill)
        doTest(\.showIndicatorFill)
        doTest(\.availableSubstances)
        doTest(\.substance)
    }

    private func doTest<T: Equatable>(_ path: KeyPath<TitrationViewModel, T>) {
        let model = TitrationViewModel()
        checkPreviousValueIsReapplied(
            model: model,
            navigation: model.navigation!,
            prevValueKeyPath: path
        )
    }
}
