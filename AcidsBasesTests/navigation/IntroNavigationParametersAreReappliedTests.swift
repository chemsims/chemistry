//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import AcidsBases

class IntroNavigationParametersAreReappliedTests: XCTestCase {

    func testParametersAreReapplied() {
        doTest(\.statement)
        doTest(\.inputState)
        doTest(\.highlights)
        doTest(\.availableSubstances)
        doTest(\.selectedSubstances)
    }

    private func doTest<T: Equatable>(_ path: KeyPath<IntroScreenViewModel, T>) {
        let model = IntroScreenViewModel(
            substancePersistence: InMemoryAcidOrBasePersistence(),
            namePersistence: InMemoryNamePersistence()
        )
        checkPreviousValueIsReapplied(
            model: model,
            navigation: model.navigation!,
            prevValueKeyPath: path
        )
    }
}
