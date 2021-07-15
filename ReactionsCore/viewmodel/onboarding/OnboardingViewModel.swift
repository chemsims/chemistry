//
// Reactions App
//

import SwiftUI

public class OnboardingViewModel: ObservableObject {

    public init() {
        self.navigation = OnboardingNavigationModel.model(self)
    }

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
                    self.name = String(newValue.prefix(Self.maxNameLength))
                }
            }
        )
    }

    func next() {
        navigation?.next()
    }

    func saveName() {
        print("Saving name...")
    }
}
