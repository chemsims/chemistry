//
// Reactions App
//

import SwiftUI

public class SharePrompter: ObservableObject {

    public init(
        persistence: SharePromptPersistence,
        appLaunches: AppLaunchPersistence,
        analytics: GeneralAppAnalytics
    ) {
        self.persistence = persistence
        self.appLaunches = appLaunches
        self.analytics = analytics
    }

    @Published public var showingPrompt = false

    let persistence: SharePromptPersistence
    let appLaunches: AppLaunchPersistence
    let analytics: GeneralAppAnalytics
    let dateProvider: DateProvider = CurrentDateProvider()

    public func dismiss() {
        analytics.dismissedSharePrompt(promptCount: getCountOfShowingPrompt())
        doDismiss()
    }

    public func clickedShare() {
        analytics.tappedShareFromPrompt(promptCount: getCountOfShowingPrompt())
        persistence.setClickedShare()
        doDismiss()
    }

    private func doDismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            showingPrompt = false
        }
    }

    func showPrompt() {
        let lastPrompt = persistence.getLastPromptInfo()
        let thisPrompt = lastPrompt?.increment(dateProvider: dateProvider) ?? .firstPrompt(dateProvider: dateProvider)
        analytics.showedSharePrompt(promptCount: thisPrompt.count)
        persistence.setSharePromptInfo(thisPrompt)
        withAnimation(.easeOut(duration: 0.3)) {
            showingPrompt = true
        }
    }

    func shouldShowPrompt() -> Bool {
        guard !persistence.clickedShare else {
            return false
        }

        if let lastPrompt = persistence.getLastPromptInfo() {
            return shouldShowPrompt(lastPrompt: lastPrompt)
        } else if let launchDate = appLaunches.dateOfFirstAppLaunch {
            return dateProvider.daysPassed(
                since: launchDate,
                days: SharePromptSettings.minDaysBetweenAppLaunchAndFirstSharePrompt
            )
        }
        return false
    }


    // Returns the count of the currently showing prompt
    // This assumes that `showPrompt` has been called, as the count in the store
    // is incremented when `showPrompt` is called.
    private func getCountOfShowingPrompt() -> Int {
        persistence.getLastPromptInfo()?.count ?? 0
    }

    private func shouldShowPrompt(lastPrompt: PromptInfo) -> Bool {
        guard let minDayGap = lastPrompt.minDayGapSincePreviousPrompt else {
            return false
        }
        return dateProvider.daysPassed(since: lastPrompt.date, days: minDayGap)
    }
}

private extension PromptInfo {
    var minDayGapSincePreviousPrompt: Int? {
        switch self.count {
        case 1: return SharePromptSettings.minDaysBetweenFirstAndSecondSharePrompt
        case 2: return SharePromptSettings.minDaysBeforeSecondAndThirdSharePrompt
        default: return nil
        }
    }
}

struct SharePromptSettings {
    private init() { }

    static let minDaysBetweenAppLaunchAndFirstSharePrompt = 7

    static let minDaysBetweenFirstAndSecondSharePrompt = 14

    static let minDaysBeforeSecondAndThirdSharePrompt = 28
}
