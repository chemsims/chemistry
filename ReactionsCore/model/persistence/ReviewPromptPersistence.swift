//
// Reactions App
//

import Foundation

public protocol ReviewPromptPersistence {
    func lastPromptedVersion() -> String?
    func setPromptedVersion(version: String)
}

public class UserDefaultsReviewPromptPersistence: ReviewPromptPersistence {

    private let defaults = UserDefaults.standard

    public init() { }

    public func lastPromptedVersion() -> String? {
        defaults.string(forKey: key)
    }

    public func setPromptedVersion(version: String) {
        defaults.setValue(version, forKey: key)
    }

    private let key = "last-review-prompt-version"
}

public class InMemoryReviewPromptPersistence: ReviewPromptPersistence {

    private var underlying: String?

    public init() { }

    public func lastPromptedVersion() -> String? {
        underlying
    }

    public func setPromptedVersion(version: String) {
        underlying = version
    }
}
