//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium

class SolubilityScreenDemoToAddSoluteRaceConditionTests: XCTestCase {

    func testParticleWaterEntryUsingDemoReactionWithTheBeakerStateHasChanged() {
        let model = SolubilityViewModel()
        model.beakerState.goTo(state: .addingSolute(type: .primary), with: .none)
        model.inputState = .addSolute(type: .primary)
        model.onParticleWaterEntry(soluteType: .primary, onBeakerState: .demoReaction)
        XCTAssertEqual(model.componentsWrapper.counts.count(of: .enteredWater), 0)
    }

}
