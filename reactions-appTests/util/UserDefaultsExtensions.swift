//
// Reactions App
//
  

import Foundation

extension UserDefaults {
    func clearAll() {
        removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
}
