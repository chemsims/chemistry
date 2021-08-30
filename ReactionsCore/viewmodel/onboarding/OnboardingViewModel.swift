//
// Reactions App
//

import SwiftUI

public class OnboardingViewModel: ObservableObject {

    public init(
        namePersistence: NamePersistence,
        analytics: GeneralAppAnalytics
    ) {
        self.namePersistence = namePersistence
        self.analytics = analytics
        self.name = namePersistence.name
        self.navigation = OnboardingNavigationModel.model(self)
    }

    private var namePersistence: NamePersistence
    private let analytics: GeneralAppAnalytics

    @Published var statement = [TextLine]()
    @Published var isProvidingName = false
    @Published var name: String?

    public private(set) var navigation: NavigationModel<OnboardingScreenState>?

    // We need to use a small limit to prevent long names breaking the UI
    private static let maxNameLength = 30

    var nextText: String {
        if !isProvidingName {
            return "Next"
        } else if name == nil {
            return "Continue without name"
        } else {
            return "Let's get started!"
        }
    }

    var nameBinding: Binding<String> {
        Binding(
            get: { self.name ?? "" },
            set: { newValue in
                let isEmpty = newValue
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
                if isEmpty {
                    self.name = nil
                } else {
                    // We don't store the trimmed name here, otherwise
                    // user would not be able to add any whitespace
                    self.name = String(newValue.prefix(Self.maxNameLength))
                }
            }
        )
    }

    func next() {
        if navigation.exists({!$0.hasNext}) {
            logCompletedOnboarding()
        }
        navigation?.next()
    }

    private func logCompletedOnboarding() {
        if let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            analytics.completedOnboardingWithName()
        } else {
            analytics.completedOnboardingWithoutName()
        }
    }

    public func saveName() {
        namePersistence.name = name?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
