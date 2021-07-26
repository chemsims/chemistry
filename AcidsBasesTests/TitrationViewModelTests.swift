//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import AcidsBases

class TitrationViewModelTests: XCTestCase {

    func testNextIsAppliedWhenMaxBufferCapacityIsReached() {
        let model = TitrationViewModel(titrationPersistence: InMemoryTitrationInputPersistence(), namePersistence: InMemoryNamePersistence())
        let nav = model.navigation
        nav?.nextUntil {
            $0.isAtState(
                substance: .weakAcid,
                phase: .preparation,
                input: .addSubstance
            )
        }

        model.increment(substance: .weakAcid, count: 50)

        nav?.nextUntil {
            $0.isAtState(
                substance: .weakAcid,
                phase: .preEP,
                input: .addTitrant
            )
        }

        let weakModel = model.components.weakSubstancePreEPModel

        model.incrementTitrant(
            count: weakModel.titrantAtMaxBufferCapacity
        )

        XCTAssertEqual(model.inputState, .none)
    }
}

private extension TitrationViewModel {
    func isAtState(
        substance: TitrationComponentState.Substance,
        phase: TitrationComponentState.Phase,
        input: TitrationViewModel.InputState
    ) -> Bool {
        let state = TitrationComponentState.State(
            substance: substance,
            phase: phase
        )
        return self.components.state == state && self.inputState == input
    }
}
