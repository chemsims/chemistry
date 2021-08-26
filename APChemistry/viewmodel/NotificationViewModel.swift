//
// Reactions App
//

import Foundation

class NotificationViewModel: ObservableObject {
    private init() { }

    static let shared = NotificationViewModel()

    static let animationDuration: TimeInterval = 0.35
    static let showDuration = 3

    @Published var notification: Notification?

    private var hideNotificationTask: DispatchWorkItem?


    func showNotification(_ notification: Notification) {
        hideNotificationTask?.cancel()

        self.notification = notification
        let task = DispatchWorkItem { self.notification = nil }
        self.hideNotificationTask = task

        DispatchQueue.main.asyncAfter(
            deadline: .now() + .seconds(Self.showDuration),
            execute: task
        )
    }


    struct Notification {
        let message: String
        let icon: NotificationCard.Icon

        var id: String {
            "\(message)\(icon)"
        }
    }
}

extension NotificationViewModel {
    static func showSuccessfulPurchaseNotification() {
        Self.shared.showNotification(
            .init(message: "Purchase successful!", icon: .tick)
        )
    }

    static func showExtraTipNotification() {
        Self.shared.showNotification(
            .init(message: "Thanks for your support!", icon: .tick)
        )
    }

    static func showRestoredNotification() {
        Self.shared.showNotification(
            .init(message: "Finished restoring purchases.", icon: .tick)
        )
    }

    static func showFailedPurchaseNotification() {
        Self.shared.showNotification(
            .init(message: "Could not complete purchase.", icon: .error)
        )
    }
}
