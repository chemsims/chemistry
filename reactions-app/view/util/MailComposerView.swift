//
// Reactions App
//
  

import SwiftUI
import MessageUI


struct MailComposerView: UIViewControllerRepresentable {

    @Binding var isShowing: Bool

    init(isShowing: Binding<Bool>) {
        assert(Self.canSendMail())
        _isShowing = isShowing
    }

    static func canSendMail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = MFMailComposeViewController()
        controller.setToRecipients([FeedbackSettings.toAddress])
        controller.setSubject(FeedbackSettings.subject)
        controller.setMessageBody(FeedbackSettings.body, isHTML: false)
        controller.mailComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isShowing: $isShowing)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool

        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            isShowing = false
        }

    }

}

struct MailComposerView_Previews: PreviewProvider {
    static var previews: some View {
        MailComposerView(isShowing: .constant(true))
    }
}
