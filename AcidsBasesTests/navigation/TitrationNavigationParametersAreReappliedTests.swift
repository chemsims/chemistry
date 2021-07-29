//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import AcidsBases

class TitrationNavigationParametersAreReappliedTests: XCTestCase {

    func testParametersAreReapplied() {
        doTest(\.statement)
        doTest(\.inputState)
        doTest(\.equationState)
        doTest(\.showTitrantFill)
        doTest(\.showIndicatorFill)
        doTest(\.availableSubstances)
        doTest(\.substance)
        doTest(\.highlights)
    }

    private func doTest<T: Equatable>(_ path: KeyPath<TitrationViewModel, T>) {
        let model = TitrationViewModel(
            titrationPersistence: InMemoryTitrationInputPersistence(),
            namePersistence: InMemoryNamePersistence.shared
        )
        checkPreviousValueIsReapplied(
            model: model,
            navigation: model.navigation!,
            prevValueKeyPath: path
        )
    }
}
