//
// Reactions App
//

import XCTest
@testable import reactions_app

class RootNavigationModelTest: XCTestCase {

    override class func setUp() {
        UserDefaults.standard.clearAll()
    }

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

    func testMenuIsShownOnFinalScreenWhenItIsNotTheFirstScreen() {
        let model = newModel()
        XCTAssertFalse(model.showMenu)
        model.jumpTo(screen: .finalAppScreen)
        XCTAssert(model.showMenu)
    }

    func testMenuIsNotShownOnFinalScreenWhenItIsTheFirstScreen() {
        let model = newModel(injector: TestInjector(screen: .finalAppScreen))
        XCTAssertFalse(model.showMenu)
        XCTAssertEqual(model.currentScreen, .finalAppScreen)
    }

    func testReviewPromptIsShownOnFinalScreenWhenItIsNotTheFirstScreen() {
        let injector = TestInjector(screen: .zeroOrderReaction)
        let model = newModel(injector: injector)
        XCTAssertNil(injector.reviewPersistence.lastPromptedVersion())

        model.jumpTo(screen: .finalAppScreen)
        let reviewPrompt = injector.reviewPersistence as! TestReviewPromptPersistence
        XCTAssertTrue(reviewPrompt.hasPrompted)
    }

    func testReviewPromptIsNotShownOnFinalScreenWhenItIsTheFirstScreen() {
        let injector = TestInjector(screen: .finalAppScreen)
        let _ = newModel(injector: injector)
        XCTAssertNil(injector.reviewPersistence.lastPromptedVersion())
    }

    private func newModel(injector: Injector = InMemoryInjector.shared) -> RootNavigationViewModel {
        RootNavigationViewModel(
            injector: injector
        )
    }
}

private class TestInjector: Injector {

    init(screen: AppScreen) {
        self.lastOpenedScreenPersistence = LastOpenedPersistence(screen: screen)
    }

    let reactionPersistence: ReactionInputPersistence = InMemoryReactionInputPersistence()

    let quizPersistence: QuizPersistence = InMemoryQuizPersistence()

    let reviewPersistence: ReviewPromptPersistence = TestReviewPromptPersistence()

    let energyPersistence: EnergyProfilePersistence = InMemoryEnergyProfilePersistence()

    let analytics: AnalyticsService = NoOpAnalytics()

    let lastOpenedScreenPersistence: LastOpenedScreenPersistence
}

private class LastOpenedPersistence: LastOpenedScreenPersistence {

    init(screen: AppScreen) {
        self.screen = screen
    }

    let screen: AppScreen

    func get() -> AppScreen? {
        screen
    }

    func set(_ screen: AppScreen) {
    }
}

private class TestReviewPromptPersistence: ReviewPromptPersistence {

    init() { }

    static let version = "v1"

    private(set) var hasPrompted = false

    func lastPromptedVersion() -> String? {
        hasPrompted ? Self.version : nil
    }

    func setPromptedVersion(version: String) {
        hasPrompted = true
    }

    let reviewPromptDelay: TimeInterval = 0
}
