//
// Reactions App
//

import StoreKit

struct ReviewPrompter {

    static func requestReview(persistence: ReviewPromptPersistence) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let previousVersion = persistence.lastPromptedVersion()
            let currentVersion = getCurrentVersion()
            if previousVersion != currentVersion {
                SKStoreReviewController.requestReview()
                persistence.setPromptedVersion(version: currentVersion)
            }
        }
    }

    static private func getCurrentVersion() -> String {
        Version.getCurrentVersion() ?? "unknown-bundle-version"
    }
}
