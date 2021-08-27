//
// Reactions App
//

import Foundation

public struct OnboardingNavigationModel {
    private init() {}

    static func model(_ viewModel: OnboardingViewModel) -> NavigationModel<OnboardingScreenState> {
        NavigationModel(model: viewModel, states: states)
    }

    private static let states: [OnboardingScreenState] = [
        SetStatement(OnboardingStatements.intro),
        ProvideName(OnboardingStatements.provideName)
    ]
}

private struct OnboardingStatements {
    static let intro: [TextLine] = [
        """
        Hey there! I'm beaky, and I'll be guiding you through this Acids & Bases unit.
        """,
        """
        I'll teach you what you need to know, and point out all the equations and charts.
        """,
        """
        Just click next to navigate through the app and you'll be an expert in no time!
        """
    ]

    static let provideName: [TextLine] = [
        """
        First of all, what should I call you?
        """,
        """
        I only use your name to know what to call you in these statements, and it's only stored
        on your device.
        """
    ]
}

public class OnboardingScreenState: ScreenState, SubState {

    public typealias Model = OnboardingViewModel
    public typealias NestedState = OnboardingScreenState

    public func apply(on model: OnboardingViewModel) {
    }

    public func reapply(on model: OnboardingViewModel) {
        apply(on: model)
    }


    public func unapply(on model: OnboardingViewModel) {
    }

    public func delayedStates(model: OnboardingViewModel) -> [DelayedState<OnboardingScreenState>] {
        []
    }

    public func nextStateAutoDispatchDelay(model: OnboardingViewModel) -> Double? {
        nil
    }
}

private class SetStatement: OnboardingScreenState {
    init(_ statement: [TextLine]) {
        self.statement = statement
    }

    private let statement: [TextLine]

    override func apply(on model: OnboardingViewModel) {
        model.statement = statement
    }
}

private class ProvideName: SetStatement {

    override func apply(on model: OnboardingViewModel) {
        super.apply(on: model)
        model.isProvidingName = true
    }

    override func unapply(on model: OnboardingViewModel) {
        super.unapply(on: model)
        model.isProvidingName = false
    }
}
