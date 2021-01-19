//
// Reactions App
//
  

import Foundation

protocol ReviewPromptPersistence {
    func lastPromptedVersion() -> String?
    func setPromptedVersion(version: String)
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
