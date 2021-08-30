//
// Reactions App
//

import Foundation

public protocol ReviewPromptPersistence {
    func getLastPromptInfo() -> PromptInfo?
    func setPromptInfo(_ info: PromptInfo)
}

public class UserDefaultsReviewPromptPersistence: ReviewPromptPersistence {

    public init() { }

    private let underlying = UserDefaultsPromptPersistence(key: UserDefaultsReviewPromptPersistence.key)

    public func getLastPromptInfo() -> PromptInfo? {
        underlying.getLastPromptInfo()
    }

    public func setPromptInfo(_ info: PromptInfo) {
        underlying.setPromptInfo(info)
    }

    private static let key = "reviewPrompt"
}

public class InMemoryReviewPromptPersistence: ReviewPromptPersistence {

    public init() { }

    private var underlying: PromptInfo?

    public func getLastPromptInfo() -> PromptInfo? {
        underlying
    }

    public func setPromptInfo(_ info: PromptInfo) {
        underlying = info
    }
}
