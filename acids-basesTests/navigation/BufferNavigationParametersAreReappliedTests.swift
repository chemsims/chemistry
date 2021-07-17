//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import acids_bases

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
        let model = BufferScreenViewModel(namePersistence: InMemoryNamePersistence())
        checkPreviousValueIsReapplied(
            model: model,
            navigation: model.navigation!,
            prevValueKeyPath: path
        )
    }
}

