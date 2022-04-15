//
// Reactions App
//

import Foundation

// TODO rename this to be unit analytics
public protocol GeneralAppAnalytics {

    func setEnabled(value: Bool)

    func tappedShareFromMenu()

    func showedSharePrompt(promptCount: Int)

    func tappedShareFromPrompt(promptCount: Int)

    func dismissedSharePrompt(promptCount: Int)

    func showedTipPrompt(promptCount: Int)

    func dismissedTipPrompt(promptCount: Int)

    func beganUnlockBadgePurchaseFromTipPrompt(promptCount: Int, productId: String)

    func beganUnlockBadgePurchaseFromMenu(productId: String)

    func attemptedReviewPrompt(promptCount: Int)

    func completedOnboardingWithName()

    func completedOnboardingWithoutName()
}


public class NoOpGeneralAnalytics: GeneralAppAnalytics {

    public init() { }

    public func setEnabled(value: Bool) {
    }

    public func tappedShareFromMenu() {
    }

    public func showedSharePrompt(promptCount: Int) {
    }

    public func tappedShareFromPrompt(promptCount: Int) {
    }

    public func dismissedSharePrompt(promptCount: Int) {
    }

    public func showedTipPrompt(promptCount: Int) {
    }

    public func dismissedTipPrompt(promptCount: Int) {
    }

    public func beganUnlockBadgePurchaseFromTipPrompt(promptCount: Int, productId: String) {
    }

    public func beganUnlockBadgePurchaseFromMenu(productId: String) {
    }

    public func attemptedReviewPrompt(promptCount: Int) {
    }

    public func completedOnboardingWithName() {
    }

    public func completedOnboardingWithoutName() {
    }
}
