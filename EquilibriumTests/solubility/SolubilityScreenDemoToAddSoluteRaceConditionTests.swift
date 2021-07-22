//
// Reactions App
//

import XCTest
@testable import Equilibrium

class SolubilityScreenDemoToAddSoluteRaceConditionTests: XCTestCase {

    func testParticleWaterEntryUsingDemoReactionWithTheBeakerStateHasChanged() {
        let model = SolubilityViewModel(persistence: InMemorySolubilityPersistence())
        model.beakerState.goTo(state: .addingSolute(type: .primary), with: .none)
        model.inputState = .addSolute(type: .primary)
        model.onParticleWaterEntry(soluteType: .primary, onBeakerState: .demoReaction)
        XCTAssertEqual(model.componentsWrapper.counts.count(of: .enteredWater), 0)
    }

}
