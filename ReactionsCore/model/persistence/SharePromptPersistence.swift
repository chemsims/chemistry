//
// Reactions App
//

import Foundation

public protocol SharePromptPersistence {

    var clickedShare: Bool { get }

    func setClickedShare()

    func getLastPromptInfo() -> PromptInfo?

    func setSharePromptInfo(_ info: PromptInfo)
}

public class UserDefaultsSharePromptPersistence: SharePromptPersistence {

    public init() { }

    private static let infoKey = "sharePrompt.info"
    private static let clickedShareKey = "sharePrompt.clickedShare"
    private let underlying = UserDefaultsPromptPersistence(key: UserDefaultsSharePromptPersistence.infoKey)

    private let userDefaults = UserDefaults.standard

    public var clickedShare: Bool {
        userDefaults.bool(forKey: Self.clickedShareKey)
    }

    public func setClickedShare() {
        userDefaults.setValue(true, forKey: Self.clickedShareKey)
    }

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

    public private(set) var clickedShare: Bool = false

    public func setClickedShare() {
        clickedShare = true
    }

    public func getLastPromptInfo() -> PromptInfo? {
        underlying
    }

    public func setSharePromptInfo(_ info: PromptInfo) {
        underlying = info
    }
}
