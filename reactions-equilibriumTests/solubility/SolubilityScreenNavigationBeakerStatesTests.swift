//
// Reactions App
//

import XCTest
@testable import reactions_equilibrium

class SolubilityScreenNavigationBeakerStatesTests: XCTestCase {

    func testDemoReactionBeakerActions() throws {
        let model = SolubilityViewModel()
        let nav = model.navigation!

        nav.nextUntilStatement(startsWith: "The higher the Ksp, then the higher the amount of ions")

        XCTAssertEqual(model.beakerState, makeState(.demoReaction, .none))

        nav.next()
        XCTAssertEqual(model.beakerState, makeState(.none, .cleanupDemoReaction))

        nav.back()
        XCTAssertEqual(model.beakerState, makeState(.demoReaction, .none))

        nav.back()
        XCTAssertEqual(model.beakerState, makeState(.none, .cleanupDemoReaction))
    }

    func testFirstReaction() {
        let model = SolubilityViewModel()
        let nav = model.navigation!

        nav.nextUntil { $0.inputState == .addSolute(type: .primary) }
        XCTAssertEqual(model.beakerState, makeState(.addingSolute(type: .primary), .none))
        XCTAssertEqual(model.inputState, .addSolute(type: .primary))


        // Statement pre add saturated solute
        nav.next()
        XCTAssertEqual(model.beakerState, makeState(.none, .none))
        XCTAssertEqual(model.inputState, .none)

        nav.back()
        XCTAssertEqual(model.beakerState, makeState(.addingSolute(type: .primary), .none))
        XCTAssertEqual(model.inputState, .addSolute(type: .primary))

        // Add saturated solute
        nav.next()
        nav.next()
        XCTAssertEqual(model.beakerState, makeState(.addingSaturatedPrimary, .none))
        XCTAssertEqual(model.inputState, .addSaturatedSolute)

        // Back to previous pre add saturated solute
        nav.back()
        XCTAssertEqual(model.beakerState, makeState(.none, .removeSolute(duration: 0.5)))
        XCTAssertEqual(model.inputState, .none)

        // Reapply add saturated solute
        nav.next()
        nav.next()
        XCTAssertEqual(model.beakerState, makeState(.none, .none))
        XCTAssertEqual(model.inputState, .none)
        nav.back()
        XCTAssertEqual(model.beakerState, makeState(.addingSaturatedPrimary, .removeSolute(duration: 0.5)))
        XCTAssertEqual(model.inputState, .addSaturatedSolute)

        nav.back()
        XCTAssertEqual(model.beakerState, makeState(.none, .removeSolute(duration: 0.5)))
        XCTAssertEqual(model.inputState, .none)

        model.currentTime = 10 // Set current time to > 0 to detect when it is reset

        // Chart shifts to prepare common ion reaction
        nav.nextUntil { $0.currentTime == 0 }
        XCTAssertEqual(model.beakerState, makeState(.none, .hideSolute(duration: 1)))
        XCTAssertEqual(model.inputState, .none)

        nav.back()
        XCTAssertEqual(model.beakerState, makeState(.none, .reAddSolute(duration: 1)))
        XCTAssertEqual(model.inputState, .none)
    }

    func testSecondReaction() {
        let model = SolubilityViewModel()
        let nav = model.navigation!

        // Adding common ion
        nav.nextUntilStatement(startsWith: "Once you add CB(S)")
        XCTAssertEqual(model.beakerState, makeState(.addingSolute(type: .commonIon), .none))
        XCTAssertEqual(model.inputState, .addSolute(type: .commonIon))

        // Reapply adding common ion
        nav.next()
        nav.back()
        XCTAssertEqual(model.beakerState, makeState(.addingSolute(type: .commonIon), .none))
        XCTAssertEqual(model.inputState, .addSolute(type: .commonIon))

        // Add primary
        nav.next()
        XCTAssertEqual(model.beakerState, makeState(.addingSolute(type: .primary), .none))
        XCTAssertEqual(model.inputState, .addSolute(type: .primary))

        // Re add add primary
        nav.next()
        nav.back()
        XCTAssertEqual(model.beakerState, makeState(.addingSolute(type: .primary), .none))
        XCTAssertEqual(model.inputState, .addSolute(type: .primary))

        // Statement pre add saturated solute
        nav.next()
        XCTAssertEqual(model.beakerState, makeState(.none, .none))
        XCTAssertEqual(model.inputState, .none)

        // Add saturated solute
        nav.next()
        XCTAssertEqual(model.beakerState, makeState(.addingSaturatedPrimary, .none))
        XCTAssertEqual(model.inputState, .addSaturatedSolute)

        // Reapply add saturated solute
        nav.next()
        nav.back()
        XCTAssertEqual(model.beakerState, makeState(.addingSaturatedPrimary, .removeSolute(duration: 0.5)))
        XCTAssertEqual(model.inputState, .addSaturatedSolute)

        nav.nextUntilStatement(startsWith: "In other words, if you add H")
        XCTAssertEqual(model.beakerState, makeState(.addingSolute(type: .acid), .none))
        XCTAssertEqual(model.inputState, .addSolute(type: .acid))

        nav.next()
        XCTAssertEqual(model.beakerState, makeState(.none, .runReaction))
        XCTAssertEqual(model.inputState, .none)

        nav.back()
        XCTAssertEqual(model.beakerState, makeState(.addingSolute(type: .acid), .undoReaction))
        XCTAssertEqual(model.inputState, .addSolute(type: .acid))

        nav.next()
        nav.next()
        XCTAssertEqual(model.beakerState, makeState(.none, .completeReaction))
        XCTAssertEqual(model.inputState, .none)

        nav.back()
        XCTAssertEqual(
            model.beakerState,
            makeState(.none, [.undoReaction, .runReaction])
        )
    }

    private func makeState(_ state: BeakerState, _ action: SKSoluteBeakerAction) -> BeakerStateTransition {
        makeState(state, [action])
    }

    private func makeState(
        _ state: BeakerState,
        _ actions: [SKSoluteBeakerAction]
    ) -> BeakerStateTransition {
        var model = BeakerStateTransition()
        model.goTo(state: state, with: actions)
        return model
    }
}

extension SolubilityViewModel: HasStatement {

}
