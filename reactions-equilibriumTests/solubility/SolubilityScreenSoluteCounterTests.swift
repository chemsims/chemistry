//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium

class SolubilityScreenSoluteCounterTests: XCTestCase {

    func testFirstReactionSaturatedSolute() {
        let model = SolubilityViewModel()
        let nav = model.navigation!

        nav.nextUntil { $0.inputState == .addSolute(type: .primary) }

        func addMax() {
            for _ in 0..<model.componentsWrapper.counts.maxAllowed {
                model.onParticleEmit(soluteType: .primary, onBeakerState: model.beakerState.state)
                model.onParticleWaterEntry(soluteType: .primary, onBeakerState: model.beakerState.state)
                model.onDissolve(soluteType: .primary, onBeakerState: model.beakerState.state)
            }
        }

        addMax()
        XCTAssertEqual(model.currentTime, SolubleReactionSettings.firstReactionTiming.equilibrium)

        nav.next()
        XCTAssertEqual(model.inputState, .addSaturatedSolute)

        addMax()
        XCTAssertEqual(model.currentTime, SolubleReactionSettings.firstReactionTiming.end)
        XCTAssertEqual(model.inputState, .none)

        nav.back()
        XCTAssertEqual(model.currentTime, SolubleReactionSettings.firstReactionTiming.equilibrium)

        XCTAssertEqual(model.componentsWrapper.counts.maxAllowed, 5)

        addMax()
        XCTAssertEqual(model.currentTime, SolubleReactionSettings.firstReactionTiming.end)
        XCTAssertEqual(model.inputState, .none)
        XCTAssertFalse(model.canEmit)
    }

}
