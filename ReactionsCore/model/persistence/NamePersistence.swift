//
// Reactions App
//

import Foundation

public protocol NamePersistence {
    var name: String? { get set }
}

public class InMemoryNamePersistence: NamePersistence {

    public init() { }

    public var name: String? = nil
}

public class UserDefaultsNamePersistence: NamePersistence {

    public init() { }
    
    public var name: String? {
        get {
            userDefaults.string(forKey: Self.key)
        }
        set {
            userDefaults.setValue(newValue, forKey: Self.key)
        }
    }

    private static let key = "addressableBy"
    private let userDefaults = UserDefaults.standard
}
