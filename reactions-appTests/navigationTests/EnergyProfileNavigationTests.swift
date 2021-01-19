//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class EnergyProfileNavigationViewModelTests: XCTestCase {

    func testThatNextIsDisabledWhileAwaitingTemp2Input() {
        let model = EnergyProfileViewModel()
        let nav = EnergyProfileNavigationViewModel.model(model)
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
}
