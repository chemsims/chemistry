//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium

class SolubilityViewModelParameterReappliedTests: XCTestCase {

    func testParametersAreReapplied() {
        doTest(\.statement)
        doTest(\.highlights.elements)
        doTest(\.inputState)
        doTest(\.reactionSelectionToggled)
        doTest(\.equationState)
        doTest(\.showSelectedReaction)
        doTest(\.reactionArrowDirection)
        doTest(\.beakerLabel)
        doTest(\.showSoluteReactionLabel)
    }

    private func doTest<T: Equatable>(_ path: KeyPath<SolubilityViewModel, T>) {
        let model = SolubilityViewModel(persistence: InMemorySolubilityPersistence())
        checkPreviousValueIsReapplied(
            model: model,
            navigation: model.navigation!,
            prevValueKeyPath: path
        )
    }

}
