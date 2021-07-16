//
// Reactions App
//

import Foundation

public protocol OnboardingPersistence {
    var hasCompletedOnboarding: Bool { get set }
}

public class InMemoryOnboardingPersistence: OnboardingPersistence {

    public init(hasCompletedOnboarding: Bool = false) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    public var hasCompletedOnboarding: Bool
}

public class UserDefaultsOnboardingPersistence: OnboardingPersistence {

    public init() { }

    public var hasCompletedOnboarding: Bool {
        get {
            userDefaults.bool(forKey: Self.key)
        }
        set {
            userDefaults.setValue(newValue, forKey: Self.key)
        }
    }

    private static let key = "hasCompletedOnboarding"
    private let userDefaults = UserDefaults.standard
}
