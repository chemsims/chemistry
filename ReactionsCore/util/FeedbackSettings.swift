//
// Reactions App
//

import Foundation

public struct FeedbackSettings {
    let toAddress: String
    let subject: String
    let body: String

    private init(
        toAddress: String,
        subject: String,
        body: String
    ) {
        self.toAddress = toAddress
        self.subject = subject
        self.body = body
    }

    private init(
        toAddress: String,
        subject: String
    ) {
        self.init(
            toAddress: toAddress,
            subject: subject,
            body: Self.defaultBody
        )
    }

    public init() {
        self.init(
            toAddress: Self.defaultAddress,
            subject: "AP Chemistry App Feedback",
            body: Self.defaultBody
        )
    }

    public static let defaultAddress = "support@reactionsrateapp.com"
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
