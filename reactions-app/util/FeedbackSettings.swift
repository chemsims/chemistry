//
// Reactions App
//

import Foundation

struct FeedbackSettings {
    private init() { }

    static let toAddress = "support@reactionsrateapp.com"
    static let subject = "Reactions Rate Feedback"
    static let body = """

    ---------
    Thank you for taking the time to send your feedback. Please add your comments above.
    \(getVersion ?? "")
    """

    static var mailToUrl: URL? {
        if let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: "mailto:\(toAddress)?subject=\(encodedSubject)&body=\(encodedBody)")
        }
        return nil
    }

    private static let getVersion = Version.getCurrentVersion().map { v in
        "Version: \(v)"
    }
}

struct ShareSettings {

    static let url = "https://apps.apple.com/us/app/reaction-rate-stem/id1531309001"
    static let message = """
    Hey, check out the Reactions Rate app! Download it at \(url).
    """
}
