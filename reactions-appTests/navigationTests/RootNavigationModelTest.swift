//
// Reactions App
//
  

import XCTest
@testable import reactions_app

class RootNavigationModelTest: XCTestCase {

    func testInitialScreen() {
        XCTAssertEqual(newModel().currentScreen, .zeroOrderReaction)
    }

    func testCanSelectOtherScreens() {
        let model = newModel()
        let screens = AppScreen.allCases.filter { $0 != .zeroOrderReaction}
        screens.forEach { screen in
            XCTAssertFalse(model.canSelect(screen: screen))
        }
    }
    
    private func newModel() -> RootNavigationViewModel {
        RootNavigationViewModel(
            persistence: InMemoryReactionInputPersistence(),
            quizPersistence: InMemoryQuizPersistence(),
            reviewPersistence: InMemoryReviewPromptPersistence()
        )
    }
}

