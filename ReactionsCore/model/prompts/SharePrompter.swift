//
// Reactions App
//

import SwiftUI

public class SharePrompter: ObservableObject {

    public init(
        persistence: SharePromptPersistence,
        appLaunches: AppLaunchPersistence
    ) {
        self.persistence = persistence
        self.appLaunches = appLaunches
    }

    @Published public var showingPrompt = false

    let persistence: SharePromptPersistence
    let appLaunches: AppLaunchPersistence
    let dateProvider: DateProvider = CurrentDateProvider()

    public func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            showingPrompt = false
        }
    }

    public func clickedShare() {
        persistence.setClickedShare()
    }

    func showPrompt() {
        let lastPrompt = persistence.getLastPromptInfo()
        let thisPrompt = lastPrompt?.increment(dateProvider: dateProvider) ?? .firstPrompt(dateProvider: dateProvider)
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
