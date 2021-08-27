//
// Reactions App
//

import Foundation

public protocol AppLaunchPersistence {
    func recordAppLaunch()

    var dateOfFirstAppLaunch: Date? { get }

    var countOfAppLaunches: Int { get }
}

public class UserDefaultsAppLaunchPersistence: AppLaunchPersistence {

    public init() { }

    private let userDefaults = UserDefaults.standard
    private static let countKey = "launches.count"
    private static let firstDateKey = "launches.firstDate"

    public func recordAppLaunch() {
        let currentCount = countOfAppLaunches
        if currentCount == 0 {
            userDefaults.set(Date(), forKey: Self.firstDateKey)
        }
        userDefaults.set(currentCount + 1, forKey: Self.countKey)
    }

    public var dateOfFirstAppLaunch: Date? {
        userDefaults.object(forKey: Self.firstDateKey) as? Date
    }

    public var countOfAppLaunches: Int {
        userDefaults.integer(forKey: Self.countKey)
    }
}

public class InMemoryAppLaunchPersistence: AppLaunchPersistence {
    public init() { }

    public private(set) var dateOfFirstAppLaunch: Date? = nil
    public private(set) var countOfAppLaunches: Int = 0

    public func recordAppLaunch() {
        if countOfAppLaunches == 0 {
            dateOfFirstAppLaunch = Date()
        }
        countOfAppLaunches += 1
    }
}
