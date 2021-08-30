//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import AcidsBases

class BufferNavigationParametersAreReappliedTests: XCTestCase {

    func testParametersAreReapplied() {
        doTest(\.statement)
        doTest(\.input)
        doTest(\.equationState)
        doTest(\.highlights)
        doTest(\.availableSubstances)
        doTest(\.substance)
    }

    private func doTest<T: Equatable>(_ path: KeyPath<BufferScreenViewModel, T>) {
        let model = BufferScreenViewModel(
            substancePersistence: InMemoryAcidOrBasePersistence(),
            namePersistence: InMemoryNamePersistence.shared
        )
        checkPreviousValueIsReapplied(
            model: model,
            navigation: model.navigation!,
            prevValueKeyPath: path
        )
    }
}

