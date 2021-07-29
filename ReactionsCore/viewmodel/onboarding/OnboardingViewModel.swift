//
// Reactions App
//

import SwiftUI

public class OnboardingViewModel: ObservableObject {

    public init(
        namePersistence: NamePersistence,
        closeOnboarding: @escaping () -> Void
    ) {
        self.namePersistence = namePersistence
        self.name = namePersistence.name
        self.navigation = OnboardingNavigationModel.model(self)
        self.navigation?.nextScreen = {
            // text field onCommit may not be called, so always save name
            self.saveName()
            closeOnboarding()
        }
    }

    private var namePersistence: NamePersistence

    @Published var statement = [TextLine]()
    @Published var isProvidingName = false
    @Published var name: String?

    private(set) var navigation: NavigationModel<OnboardingScreenState>?

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
        navigation?.next()
    }

    func saveName() {
        namePersistence.name = name?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
