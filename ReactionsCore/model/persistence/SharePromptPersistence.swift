//
// Reactions App
//

import Foundation

public protocol SharePromptPersistence {

    func getLastPromptInfo() -> PromptInfo?

    func setSharePromptInfo(_ info: PromptInfo)
}

public class UserDefaultsSharePromptPersistence: SharePromptPersistence {

    public init() { }

    private static let key = "sharePrompts"
    private let underlying = UserDefaultsPromptPersistence(key: UserDefaultsSharePromptPersistence.key)

    public func getLastPromptInfo() -> PromptInfo? {
        underlying.getLastPromptInfo()
    }

    public func setSharePromptInfo(_ info: PromptInfo) {
        underlying.setPromptInfo(info)
    }
}

public class InMemorySharePromptPersistence: SharePromptPersistence {

    public init() { }

    private var underlying: PromptInfo?

    public func getLastPromptInfo() -> PromptInfo? {
        underlying
    }

    public func setSharePromptInfo(_ info: PromptInfo) {
        underlying = info
    }
}
