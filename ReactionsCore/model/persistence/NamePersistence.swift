//
// Reactions App
//

import Foundation

public protocol NamePersistence {
    var name: String? { get set }
}

extension NamePersistence {
    /// Returns the name preceded by a comma, or an empty string.
    ///
    ///  # Examples
    ///
    /// ```
    /// let persistence: NamePersistence = ...
    /// persistence.name = "Bob"
    ///
    /// "Hello\(persistence.nameWithComma)!" // Hello, Bob!
    ///
    /// persistence.name = nil
    /// "Hello\(persistence.nameWithComma)!" // Hello!
    /// ```
    ///  `let persistence: NamePersistence = ...`

    ///  `persistence.name = "Bob"`
    ///
    /// `"Hello\(persistence.nameWithComma)!"` // Hello, Bob!
    ///
    ///  `persistence.name = nil`
    ///
    ///  `"Hello\(persistence.nameWithComma)!"` // Hello!
    public var nameWithComma: String {
        name.map { ", \($0)" } ?? ""
    }

    public static var inMemory: NamePersistence {
        InMemoryNamePersistence.shared
    }
}

public class InMemoryNamePersistence: NamePersistence {

    private init() { }

    public static let shared = InMemoryNamePersistence()

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
