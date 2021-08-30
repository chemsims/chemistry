//
// Reactions App
//

import ReactionsCore
import SwiftUI

class TipOverlayViewModel: ObservableObject {

    init(
        persistence: TipOverlayPersistence,
        locker: ProductLocker,
        analytics: GeneralAppAnalytics
    ) {
        self.persistence = persistence
        self.locker = locker
        self.analytics = analytics
    }

    @Published private(set) var showModal = false
    private var persistence: TipOverlayPersistence
    private let locker: ProductLocker
    private let analytics: GeneralAppAnalytics
    private let dateProvider: DateProvider = CurrentDateProvider()

    func show() {
        withAnimation(.easeOut(duration: 0.25)) {
            showModal = true
        }
        let lastPrompt = persistence.lastPrompt
        let thisPrompt = lastPrompt?.increment(dateProvider: dateProvider) ?? .firstPrompt(dateProvider: dateProvider)
        persistence.lastPrompt = thisPrompt
        analytics.showedTipPrompt(promptCount: thisPrompt.count)
    }

    func continuePostTip() {
        doHide()
    }

    func dismissWithoutTip() {
        if showModal { // Check if showing to prevent double taps registering 2 events
            analytics.dismissedTipPrompt(promptCount: getCountOfCurrentlyShowingTipPrompt())
        }
        doHide()
    }

    /// Returns count of the currently showing tip prompt, which assumes
    /// that `show` has already been called.
    func getCountOfCurrentlyShowingTipPrompt() -> Int {
        persistence.lastPrompt?.count ?? 0
    }

    private func doHide() {
        withAnimation(.easeOut(duration: 0.25)) {
            showModal = false
        }
    }

    func shouldShowTipOverlay() -> Bool {
        let hasTipped = UnlockBadgeTipLevel.allCases.contains { level in
            locker.isUnlocked(level.product)
        }
        guard !hasTipped else {
            return false
        }
        if let lastPrompt = persistence.lastPrompt {
            return shouldShowTipOverlay(lastPrompt)
        }
        return true
    }

    private func shouldShowTipOverlay(_ lastPrompt: PromptInfo) -> Bool {
        guard let minDayGap = lastPrompt.minDayGapSincePreviousPrompt else {
            return false
        }
        return dateProvider.daysPassed(since: lastPrompt.date, days: minDayGap)
    }
}

private extension PromptInfo {
    var minDayGapSincePreviousPrompt: Int? {
        switch self.count {
        case 1: return TipSettings.minDaysBetweenFirstAndSecondTipPrompt
        case 2: return TipSettings.minDaysBetweenSecondAndThirdTipPrompt
        default: return nil
        }
    }
}

private struct TipSettings {
    static let minDaysBetweenFirstAndSecondTipPrompt = 7
    static let minDaysBetweenSecondAndThirdTipPrompt = 14
}

protocol TipOverlayPersistence {

    var lastPrompt: PromptInfo? { get set }
}

class UserDefaultsTipOverlayPersistence: TipOverlayPersistence {
    private static let key = "supportModal"

    private let underlying = UserDefaultsPromptPersistence(key: UserDefaultsTipOverlayPersistence.key)

    var lastPrompt: PromptInfo? {
        get {
            underlying.getLastPromptInfo()
        }
        set {
            if let info = newValue {
                underlying.setPromptInfo(info)
            }
        }
    }

    private let userDefaults = UserDefaults.standard
}

class InMemoryTipOverlayPersistence: TipOverlayPersistence {
    var lastPrompt: PromptInfo? = nil
}
