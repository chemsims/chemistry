//
// Reactions App
//

import Foundation

struct Version {
    private init() { }

    static func getCurrentVersion() -> String? {
        if let v = getVersion(), let b = getBuild() {
            return "\(v) (\(b))"
        }
        return nil
    }

    private static func getVersion() -> String? {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String
    }

    private static func getBuild() -> String? {
        let key = kCFBundleVersionKey as String?
        return key.flatMap { k in
            Bundle.main.object(forInfoDictionaryKey: k) as? String
        }
    }
}
