//
// Reactions App
//
  

import Foundation

struct FeedbackSettings {
    private init() { }

    static let toAddress = "cogsci7@gmail.com"
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

