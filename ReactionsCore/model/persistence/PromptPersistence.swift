//
// Reactions App
//

import Foundation

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
