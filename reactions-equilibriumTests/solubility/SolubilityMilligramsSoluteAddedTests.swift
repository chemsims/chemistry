//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium

class SolubilityMilligramsSoluteAddedTests: XCTestCase {

    func testLabelIsResetWhenGoingBackAndNextOnFirstReaction() {
        let model = SolubilityViewModel(persistence: InMemorySolubilityPersistence())
        let nav = model.navigation!

        nav.nextUntil { $0.inputState == .addSolute(type: .primary) }
        XCTAssertEqual(model.milligramsSoluteAdded, 0)

        model.addVoiceOverParticle(soluteType: .primary)

        let expected = CGFloat(SolubleReactionSettings.milligrams(for: 1))
        XCTAssertEqual(model.milligramsSoluteAdded, expected)

        model.back()
        model.next()
        XCTAssertEqual(model.milligramsSoluteAdded, 0)
    }

    // This case can occur when the user shakes molecule into the beaker, goes back, and then goes
    // next before that molecule has dissolved. When the molecule dissolves it will cause the reaction
    // to move forward, so the mg added must be updated too
    func testLabelIsSetCorrectlyWhenMoleculeDissolvesAfterGoingBackAndNextOnFirstReaction() {
        let model = SolubilityViewModel(persistence: InMemorySolubilityPersistence())
        let nav = model.navigation!

        nav.nextUntil { $0.inputState == .addSolute(type: .primary) }

        model.onParticleWaterEntry(soluteType: .primary, onBeakerState: .addingSolute(type: .primary))
        let expected = CGFloat(SolubleReactionSettings.milligrams(for: 1))
        XCTAssertEqual(model.milligramsSoluteAdded, expected)

        model.back()
        model.next()
        model.onDissolve(soluteType: .primary, onBeakerState: .addingSolute(type: .primary))
        XCTAssertGreaterThan(model.currentTime, 0)
        XCTAssertEqual(model.milligramsSoluteAdded, expected)
    }
}
