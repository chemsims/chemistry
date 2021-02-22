//
// Reactions App
//

import Foundation

protocol ReviewPromptPersistence {
    func lastPromptedVersion() -> String?
    func setPromptedVersion(version: String)
}

class UserDefaultsReviewPromptPersistence: ReviewPromptPersistence {

    private let defaults = UserDefaults.standard

    func lastPromptedVersion() -> String? {
        defaults.string(forKey: key)
    }

    func setPromptedVersion(version: String) {
        defaults.setValue(version, forKey: key)
    }

    private let key = "last-review-prompt-version"
}

class InMemoryReviewPromptPersistence: ReviewPromptPersistence {

    private var underlying: String?

    func lastPromptedVersion() -> String? {
        underlying
    }

    func setPromptedVersion(version: String) {
        underlying = version
    }
}
