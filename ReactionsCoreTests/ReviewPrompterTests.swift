//
// Reactions App
//

import XCTest
@testable import ReactionsCore

class ReviewPrompterTests: XCTestCase {

    func testThatPromptShouldBeShownWhenBehaviourRequestsItOnlyIfItIsTheFirstPromptAndEnoughTimeHasPassed() {
        let modelWithFirstLaunchNow = newModel(initialCount: 0, firstLaunch: Date())
        XCTAssertFalse(modelWithFirstLaunchNow.shouldRequestReview(navBehaviourRequestsReview: true))

        let offset = ReviewPromptSettings.minDaysBetweenAppLaunchAndFirstReviewPrompt.seconds + 500
        let oldDate = Date().addingTimeInterval(-offset)
        let modelWithOldFirstLaunch = newModel(initialCount: 0, firstLaunch: oldDate)

        XCTAssert(modelWithOldFirstLaunch.shouldRequestReview(navBehaviourRequestsReview: true))

        modelWithFirstLaunchNow.requestReview()
        XCTAssertFalse(modelWithOldFirstLaunch.shouldRequestReview(navBehaviourRequestsReview: false))
    }

    func testThatPromptIsShownWhenMinimumGapHasPastBetweenPreviousPrompt() {
        let modelWithNoGapBetweenPrompts = newModel(initialCount: 1, currentDate: Date())
        XCTAssertFalse(modelWithNoGapBetweenPrompts.shouldRequestReview(navBehaviourRequestsReview: false))

        // add some extra seconds otherwise this date occurs before the date of the
        // last prompt which is set when creating the new model
        let currentDate = Date().advanced(
            by: ReviewPromptSettings.minDaysBetweenFirstAndSecondReviewPrompt.seconds + 100
        )
        let modelWithGapBetweenPrompts = newModel(initialCount: 1, currentDate: currentDate)
        XCTAssert(modelWithGapBetweenPrompts.shouldRequestReview(navBehaviourRequestsReview: false))
    }

    private func daysToInterval(_ days: Int) -> TimeInterval {
        TimeInterval(days * 86400)
    }

    private func newModel(
        initialCount: Int,
        firstLaunch: Date? = nil,
        currentDate: Date? = nil
    ) -> ReviewPrompter {
        return ReviewPrompter(
            persistence: TestReviewPromptPersistence(initialCount: initialCount),
            appLaunches: TestAppLaunchPersistence(firstLaunch: firstLaunch ?? Date()),
            analytics: NoOpGeneralAnalytics(),
            dateProvider: currentDate.map(FixedDateProvider.init) ?? CurrentDateProvider()
        )
    }
}

private extension Int {
    // converts int value from days to seconds
    var seconds: TimeInterval {
        TimeInterval(self * 86400)
    }
}

private class TestReviewPromptPersistence: ReviewPromptPersistence {
    init(initialCount: Int, lastDate: Date? = nil) {
        if initialCount > 0 {
            underlying = .firstPrompt()
            (0..<initialCount - 1).forEach { _ in underlying = underlying?.increment() }
        } else {
            underlying = nil
        }
    }

    private var underlying: PromptInfo?

    func getLastPromptInfo() -> PromptInfo? {
        underlying
    }

    func setPromptInfo(_ info: PromptInfo) {
        underlying = info
    }
}

private class TestAppLaunchPersistence: AppLaunchPersistence {
    init(firstLaunch: Date) {
        self.dateOfFirstAppLaunch = firstLaunch
    }

    private(set) var dateOfFirstAppLaunch: Date?
    private(set) var countOfAppLaunches: Int = 0

    func recordAppLaunch() {
    }
}
