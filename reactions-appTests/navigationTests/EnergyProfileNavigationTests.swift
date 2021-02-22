//
// Reactions App
//

import XCTest
@testable import reactions_app

class EnergyProfileNavigationViewModelTests: XCTestCase {

    func testThatNextIsDisabledWhileAwaitingTemp2Input() {
        let model = EnergyProfileViewModel()
        let nav = EnergyProfileNavigationViewModel.model(model, persistence: InMemoryEnergyProfilePersistence())
        model.navigation = nav

        nav.nextUntil { $0.statement.first!.debugDescription.starts(with: "Let's try to produce C") }
        XCTAssertFalse(model.canClickNext)
        XCTAssertEqual(model.reactionState, .running)

        model.next()
        XCTAssertFalse(model.canClickNext)
        XCTAssertEqual(model.reactionState, .running)

        model.temp2 = 500
        XCTAssertTrue(model.canClickNext)

        model.next()
        XCTAssertEqual(model.reactionState, .completed)
        XCTAssertTrue(model.canClickNext)

        model.back()
        XCTAssertEqual(model.reactionState, .running)
        XCTAssertFalse(model.canClickNext)

        model.back()
        XCTAssertTrue(model.canClickNext)
    }

    func testThatTheUserInputIsSavedAtTheEndOfTheNavigation() {
        let model = EnergyProfileViewModel()
        let persistence = InMemoryEnergyProfilePersistence()
        let nav = EnergyProfileNavigationViewModel.model(model, persistence: persistence)
        model.navigation = nav

        model.selectedReaction = .Second
        nav.nextUntil { $0.catalystState == .active }
        model.catalystToSelect = .C

        nav.next()
        nav.nextUntil { $0.catalystState == .active }
        model.catalystToSelect = .A

        nav.next()
        nav.nextUntil { $0.catalystState == .active }
        model.catalystToSelect = .B

        nav.next()
        nav.nextUntil { $0.reactionState == .completed }

        let expectedInput = EnergyProfileInput(
            catalysts: [.C, .A, .B],
            order: .Second
        )
        XCTAssertEqual(persistence.getInput(), expectedInput)
    }
}
