//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class RootNavigationModelTest: XCTestCase {

    func testInitialScreen() {
        let model = RootNavigationViewModel(persistence: InMemoryReactionInputPersistence())
        XCTAssertEqual(model.currentScreen, .zeroOrderReaction)
    }

    func testCanSelectOtherScreens() {
        let model = RootNavigationViewModel(persistence: InMemoryReactionInputPersistence())
        let screens = AppScreen.allCases.filter { $0 != .zeroOrderReaction}
        screens.forEach { screen in
            XCTAssertFalse(model.canSelect(screen: screen))
        }
    }

}
