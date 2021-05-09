//
// Reactions App
//

import SwiftUI
import MessageUI

struct MailComposerView: UIViewControllerRepresentable {

    let settings: FeedbackSettings
    let onDismiss: () -> Void

    init(settings: FeedbackSettings, onDismiss: @escaping () -> Void) {
        assert(Self.canSendMail())
        self.settings = settings
        self.onDismiss = onDismiss
    }

    static func canSendMail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = MFMailComposeViewController()
        controller.setToRecipients([settings.toAddress])
        controller.setSubject(settings.subject)
        controller.setMessageBody(settings.body, isHTML: false)
        controller.mailComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            onDismiss()
        }

    }
}


