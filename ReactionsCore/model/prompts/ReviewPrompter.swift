//
// Reactions App
//

import StoreKit

struct ReviewPrompter {

    init(
        persistence: ReviewPromptPersistence,
        appLaunches: AppLaunchPersistence,
        analytics: GeneralAppAnalytics,
        dateProvider: DateProvider = CurrentDateProvider()
    ) {
        self.persistence = persistence
        self.appLaunches = appLaunches
        self.analytics = analytics
        self.dateProvider = dateProvider
    }

    let persistence: ReviewPromptPersistence
    let appLaunches: AppLaunchPersistence
    let analytics: GeneralAppAnalytics
    let dateProvider: DateProvider

    static let minDaysBeforeSecondPrompt = 7
    static let minDaysBeforeThirdPrompt = 28

    public func requestReview() {
        let lastPrompt = persistence.getLastPromptInfo()
        let thisPrompt = lastPrompt?.increment(dateProvider: dateProvider) ?? .firstPrompt(dateProvider: dateProvider)
        SKStoreReviewController.requestReview()
        analytics.attemptedReviewPrompt(promptCount: thisPrompt.count)
        persistence.setPromptInfo(thisPrompt)
    }

    public func shouldRequestReview(
        navBehaviourRequestsReview: Bool
    ) -> Bool {
        let launchDate = appLaunches.dateOfFirstAppLaunch ?? dateProvider.now()
        if let lastPrompt = persistence.getLastPromptInfo() {
            return shouldRequestReview(lastPrompt: lastPrompt)
        }

        return navBehaviourRequestsReview && daysHavePassed(
            since: launchDate,
            days: ReviewPromptSettings.minDaysBetweenAppLaunchAndFirstReviewPrompt
        )
    }

    private func shouldRequestReview(lastPrompt: PromptInfo) -> Bool {
        guard let minDayGap = lastPrompt.minDayGapSincePreviousPrompt else {
            return false
        }
        return dateProvider.daysPassed(since: lastPrompt.date, days: minDayGap)
    }

    private func daysHavePassed(since date: Date, days: Int) -> Bool {
        date.distance(to: dateProvider.now()) >= days.seconds
    }
}

private extension PromptInfo {
    var minDayGapSincePreviousPrompt: Int? {
        switch self.count {
        case 1: return ReviewPromptSettings.minDaysBetweenFirstAndSecondReviewPrompt
        case 2: return ReviewPromptSettings.minDaysBeforeSecondAndThirdReviewPrompt
        default: return nil
        }
    }
}

private extension Int {
    // converts int value from days to seconds
    var seconds: TimeInterval {
        TimeInterval(self * 86400)
    }
}

struct ReviewPromptSettings {
    private init() { }
    
    static let minDaysBetweenAppLaunchAndFirstReviewPrompt = 7

    static let minDaysBetweenFirstAndSecondReviewPrompt = 14

    static let minDaysBeforeSecondAndThirdReviewPrompt = 28
}
