//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import reactions_app

class RootNavigationModelTest: XCTestCase {

    func testInitialScreen() {
        XCTAssertEqual(newModel().currentScreen, .zeroOrderReaction)
    }

    func testCanSelectOtherScreens() {
        let model = newModel()
        let screens = AppScreen.allCases.filter { $0 != .zeroOrderReaction}
        screens.forEach { screen in
            XCTAssertFalse(model.canSelect(screen: screen), "\(screen)")
        }
    }

    private func newModel() -> RootNavigationViewModel<ConcreteInjector> {
        ReactionRateNavigationModel.navigationModel(using: InMemoryInjector())
    }
}
