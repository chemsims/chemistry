//
// Reactions App
//

import SwiftUI

class SharePromptViewModel: ObservableObject {

    init(persistence: SharePromptPersistence) {
        self.persistence = persistence
    }

    @Published var showPrompt = true
    let persistence: SharePromptPersistence

    func show() {
        withAnimation(.easeOut(duration: 0.25)) {
            showPrompt = true
        }
        savePersistenceShown()
    }

    func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            showPrompt = false
        }
    }

    // TODO
    func shouldShowPrompt() -> Bool {
        true
    }

    private func savePersistenceShown() {
        let lastPrompt = persistence.getLastPromptInfo()
        let thisPrompt = lastPrompt?.incrementPrompt() ?? PromptInfo.firstPrompt()
        persistence.setSharePromptInfo(thisPrompt)
    }
}

protocol SharePromptPersistence {

    func getLastPromptInfo() -> PromptInfo?

    func setSharePromptInfo(_ info: PromptInfo)
}

class UserDefaultsSharePromptPersistence: SharePromptPersistence {

    private static let key = "sharePrompts"
    private let underlying = UserDefaultsPromptPersistence(key: UserDefaultsSharePromptPersistence.key)

    func getLastPromptInfo() -> PromptInfo? {
        underlying.getLastPromptInfo()
    }

    func setSharePromptInfo(_ info: PromptInfo) {
        underlying.setPromptInfo(info)
    }
}

class InMemorySharePromptPersistence: SharePromptPersistence {
    private var underlying: PromptInfo?

    func getLastPromptInfo() -> PromptInfo? {
        underlying
    }

    func setSharePromptInfo(_ info: PromptInfo) {
        underlying = info
    }
}

class UserDefaultsPromptPersistence {

    init(key: String) {
        self.key = key
    }

    let key: String

    private let userDefaults = UserDefaults.standard

    func getLastPromptInfo() -> PromptInfo? {
        if let data = userDefaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode(PromptInfo.self, from: data) {
            return decoded
        }
        return nil
    }

    func setPromptInfo(_ info: PromptInfo) {
        if let data = try? JSONEncoder().encode(info) {
            userDefaults.setValue(data, forKey: key)
        }
    }
}
