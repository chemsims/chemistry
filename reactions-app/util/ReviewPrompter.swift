//
// Reactions App
//

import StoreKit

struct ReviewPrompter {

    static let defaultDelay: TimeInterval = 2

    static func requestReview(persistence: ReviewPromptPersistence) {
        if persistence.reviewPromptDelay == 0 {
            doRequestReview(persistence: persistence)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + persistence.reviewPromptDelay) {
                doRequestReview(persistence: persistence)
            }
        }
    }

    private static func doRequestReview(persistence: ReviewPromptPersistence) {
        let previousVersion = persistence.lastPromptedVersion()
        let currentVersion = getCurrentVersion()
        if previousVersion != currentVersion {
            SKStoreReviewController.requestReview()
            persistence.setPromptedVersion(version: currentVersion)
        }
    }

    static private func getCurrentVersion() -> String {
        Version.getCurrentVersion() ?? "unknown-bundle-version"
    }
}
