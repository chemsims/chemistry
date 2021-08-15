//
// Reactions App
//

import XCTest
import ReactionsCore
@testable import ReactionRates

class RootNavigationModelTest: XCTestCase {

    func testInitialScreen() {
        XCTAssertEqual(newModel().currentScreen, .zeroOrderReaction)
    }

    func testCanSelectOtherScreens() {
        let model = newModel()
        let screens = ReactionRatesScreen.allCases.filter { $0 != .zeroOrderReaction}
        screens.forEach { screen in
            XCTAssertFalse(model.canSelect(screen: screen), "\(screen)")
        }
    }

    private func newModel() -> RootNavigationViewModel<ReactionRatesNavInjector> {
        ReactionRateNavigationModel.navigationModel(using: InMemoryReactionRatesInjector())
    }
}
