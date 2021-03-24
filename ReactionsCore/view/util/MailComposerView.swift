//
// Reactions App
//

import SwiftUI
import MessageUI


public struct FeedbackSettings {
    let toAddress: String
    let subject: String
    let body: String

    public init(
        toAddress: String,
        subject: String,
        body: String
    ) {
        self.toAddress = toAddress
        self.subject = subject
        self.body = body
    }

    public init(
        toAddress: String,
        subject: String
    ) {
        self.init(
            toAddress: toAddress,
            subject: subject,
            body: Self.defaultBody
        )
    }

    private static let defaultBody = """

    ---------
    Thank you for taking the time to send your feedback. Please add your comments above.
    \(getVersion ?? "")
    """

    private static let getVersion = Version.getCurrentVersion().map { v in
        "Version: \(v)"
    }

    var mailToUrl: URL? {
        if let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: "mailto:\(toAddress)?subject=\(encodedSubject)&body=\(encodedBody)")
        }
        return nil
    }
}

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
