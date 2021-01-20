//
// Reactions App
//
  

import Foundation

struct Version {
    private init() { }

    static func getCurrentVersion() -> String? {
        let key = kCFBundleVersionKey as String?
        return key.flatMap { k in
            Bundle.main.object(forInfoDictionaryKey: k) as? String
        }
    }

}
