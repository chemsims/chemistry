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
        let screens = AppScreen.allCases.filter { $0 != .zeroOrderReaction}
        screens.forEach { screen in
            XCTAssertFalse(model.canSelect(screen: screen), "\(screen)")
        }
    }

    private func newModel() -> RootNavigationViewModel<ReactionRatesInjector> {
        ReactionRateNavigationModel.navigationModel(
            using: InMemoryInjector(),
            sharePrompter: SharePrompter(
                persistence: InMemorySharePromptPersistence(),
                appLaunches: InMemoryAppLaunchPersistence()
            ),
            appLaunchPersistence: InMemoryAppLaunchPersistence()
        )
    }
}
